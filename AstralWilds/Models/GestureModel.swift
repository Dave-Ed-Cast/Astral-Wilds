//
//  Parameters.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 21/12/24.
//

import ARKit
import SwiftUI

/// A model that contains up-to-date hand coordinate information.
/// This class also holds custom gestures.
///
/// Supported custom gestures available: `Snap`
///  -  This is built with `accessibility` in mind. Humans can snap with three possible fingers and two possible hands.
///     Up to `six` possible cases, all of them are consistently handled.
@MainActor @Observable
final class GestureModel {
    
    /// Varaibles for the hand tracking
    private let session = ARKitSession()
    private var handTracking = HandTrackingProvider()
    
    /// The variable holding the latest tracked hand
    private var latestHandTracking: HandsUpdates = .init()
    
    /// Time variable to understand if a `snap`  happened
    ///
    /// A 2021 California study found out a snap occurs in 7 ms.
    /// Due to concurrency, it's safer to use a 7.5ms threshold to confirm a snap, based on testing.
    private var detectedContactTime: TimeInterval = 0
    
    /// Represents the state of a finger during gesture detection
    ///
    /// Check the variables `leftFingerStates` or `leftFingerStates` for example usage.
    ///
    /// - Parameters:
    ///   - isContacting: Whether the finger is in contact with the thumb
    ///   - contactTime: The timestamp of the contact
    ///   - initialDistanceToDestination: Tracks the initial distance from the finger that needs the snap, to the destination from when the contact began
    private struct FingerSnapState {
        var isContacting: Bool = false
        var contactTime: TimeInterval = 0
        var initialDistanceToDestination: Float = 0
    }
    
    /// The updated dictionaries now track each finger’s state separately per hand.
    private var leftFingerStates: [HandSkeleton.JointName: FingerSnapState] = [
        .indexFingerTip: FingerSnapState(),
        .middleFingerTip: FingerSnapState(),
        .ringFingerTip: FingerSnapState()
    ]
    private var rightFingerStates: [HandSkeleton.JointName: FingerSnapState] = [
        .indexFingerTip: FingerSnapState(),
        .middleFingerTip: FingerSnapState(),
        .ringFingerTip: FingerSnapState()
    ]

    
    /// Holds the latest hand anchor information for the hands.
    private struct HandsUpdates {
        var left: HandAnchor?
        var right: HandAnchor?
        
        init() {
            self.left = nil
            self.right = nil
        }
    }
    
    /// The possible fingers that can snap
    private let fingers: [HandSkeleton.JointName] = [
        .indexFingerTip,
        .middleFingerTip,
        .ringFingerTip
    ]
        
    /// Use this supervisor to detect if a snap occurs. It will be true once the snap has occurred.
    var didThanosSnap: Bool = false
        
    /// Start the hand tracking session.
    func startTrackingSession() async {
        do {
            if HandTrackingProvider.isSupported {
                try await session.run([handTracking])
                print("ARKitSession starting.")
            }
        } catch {
            print("ARKitSession error:", error)
        }
    }
    
    /// Updates the hand tracking session differentiating the cases of updates.
    /// This function ignores every state except the update.
    /// It works on the `MainActor`, while updating, and checks the gestures through a `Task.detached`
    func updateTracking() async {
        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .updated:
                let anchor = update.anchor
                guard anchor.isTracked else { continue }
                
                //If tracked, update the latest state
                await MainActor.run {
                    if anchor.chirality == .left {
                        latestHandTracking.left = anchor
                    } else if anchor.chirality == .right {
                        latestHandTracking.right = anchor
                    }
                }
                
                //Then, create the task.
                //This could be optimised and will later in the future.
                Task.detached { [self] in
                    
                    let leftSnap = await thanosSnap(for: "left", fingers: fingers)
                    let rightSnap = await thanosSnap(for: "right", fingers: fingers)
                    
                    if leftSnap || rightSnap {
                        await MainActor.run {
                            didThanosSnap = true
                        }
                        try? await Task.sleep(for: .seconds(0.25))
                        await MainActor.run {
                            didThanosSnap = false
                        }
                    }
                }
                
            default:
                break
            }
        }
        
    }
    
    /// Detects a snapping gesture starting from the thumb and the specified finger (index, middle, or ring) of the specified hand.
    ///
    /// This function has been built through countless user testing and has finally been optimised to a very consistent level.
    /// However, it is still always monitored for optimisation.
    ///
    /// A per-finger state used to track the contact and snapping motion.
    /// Detects a snapping gesture for a specific hand using a state-machine per finger.
    ///
    /// - Parameters:
    ///   - handSide: Specify "left" or "right" to detect snap gestures for the respective hand.
    ///   - fingers: The fingers that can execute the snap gesture.
    /// - Returns: `True` if the user snapped with one of the designated fingers with either one or both hands simultaneously.
    private func thanosSnap(for handSide: String, fingers: [HandSkeleton.JointName]) -> Bool {
        guard let handAnchor = (handSide == "left" ? latestHandTracking.left : latestHandTracking.right),
              let handSkeleton = handAnchor.handSkeleton,
              handAnchor.isTracked else {
            resetFingerStates(for: handSide)
            return false
        }
        
        let origin = handAnchor.originFromAnchorTransform
        let joint = handSkeleton.joint
        
        let thumbTip = joint(.thumbTip).anchorFromJointTransform
        let thumbKnuckle = joint(.thumbKnuckle).anchorFromJointTransform
        
        let thumbPosition = matrix_multiply(origin, thumbTip).columns.3.xyz
        let thumbKnucklePosition = matrix_multiply(origin, thumbKnuckle).columns.3.xyz
        
        let currentTime = Date().timeIntervalSince1970
        
        let snapTimeThreshold: TimeInterval = 0.025
        let maxContactDuration: TimeInterval = 0.05
        let minMovementDistance: Float = 0.04
        let contactThreshold: Float = 0.02
        let destinationThreshold: Float = 0.125
        
        for finger in fingers {
            
            let fingerPosition = matrix_multiply(origin, joint(finger).anchorFromJointTransform).columns.3.xyz
            let distanceThumbFinger = simd_precise_distance(thumbPosition, fingerPosition)
            let distanceFingerDestination = simd_precise_distance(fingerPosition, thumbKnucklePosition)
            
            var state = fingerState(for: handSide, finger: finger)
            
            if !state.isContacting {
                if distanceThumbFinger < contactThreshold {
                    state.isContacting = true
                    state.contactTime = currentTime
                    state.initialDistanceToDestination = distanceFingerDestination
                    saveFingerState(for: handSide, finger: finger, state: state)
                }
            } else {
                let elapsed = currentTime - state.contactTime
                if elapsed <= snapTimeThreshold &&
                    distanceFingerDestination < destinationThreshold &&
                    (state.initialDistanceToDestination - distanceFingerDestination) > minMovementDistance {
                    
                    resetFingerState(for: handSide, finger: finger)
                    
                    print("Data for snap! \n")
                    print("elapsedTime: \(elapsed)\n distanceFingerDestination: \(distanceFingerDestination)\n stata.initialDistanceToDestination: \(state.initialDistanceToDestination)\n")
                    return true
                }
                if elapsed > maxContactDuration {
                    resetFingerState(for: handSide, finger: finger)
                }
            }
        }
        
        return false
    }

    /// Helper: Retrieve the current state for a given finger.
    private func fingerState(for handSide: String, finger: HandSkeleton.JointName) -> FingerSnapState {
        if handSide == "left" {
            return leftFingerStates[finger] ?? FingerSnapState()
        } else {
            return rightFingerStates[finger] ?? FingerSnapState()
        }
    }

    /// Helper: Save the updated state for a given finger.
    private func saveFingerState(for handSide: String, finger: HandSkeleton.JointName, state: FingerSnapState) {
        if handSide == "left" {
            leftFingerStates[finger] = state
        } else {
            rightFingerStates[finger] = state
        }
    }

    /// Helper: Reset a finger’s state.
    private func resetFingerState(for handSide: String, finger: HandSkeleton.JointName) {
        saveFingerState(for: handSide, finger: finger, state: FingerSnapState())
    }

    /// Helper: Reset all finger states for a given hand.
    private func resetFingerStates(for handSide: String) {
        for finger in fingers {
            resetFingerState(for: handSide, finger: finger)
        }
    }
}
