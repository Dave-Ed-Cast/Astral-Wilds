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
    
    
    /// These variables hold the information of the finger that was last in contact for the `Snap` gesture
    private var leftContactIndex: Bool = false
    private var leftContactMiddle: Bool = false
    private var leftContactRing: Bool = false
    private var rightContactIndex: Bool = false
    private var rightContactMiddle: Bool = false
    private var rightContactRing: Bool = false
    
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
            resetState()
            return false
        }
        
        let origin = handAnchor.originFromAnchorTransform
        let joint = handSkeleton.joint
        
        let thumbTip = joint(.thumbTip).anchorFromJointTransform
        let thumbKnuckle = joint(.thumbKnuckle).anchorFromJointTransform
        
        let thumbPosition = matrix_multiply(origin, thumbTip).columns.3.xyz
        let thumbKnucklePosition = matrix_multiply(origin, thumbKnuckle).columns.3.xyz
                
        let contactThreshold: Float = 0.0225
        let destinationThreshold: Float = 0.08
        
        let currentTime = Date().timeIntervalSince1970
        
                
        for finger in fingers {
            
            let fingerAnchor = joint(finger).anchorFromJointTransform
            let fingerPosition = matrix_multiply(origin, fingerAnchor).columns.3.xyz
            let distanceThumbFinger = simd_precise_distance(thumbPosition, fingerPosition)
            let distanceFingerDestination = simd_precise_distance(fingerPosition, thumbKnucklePosition)
            
            if distanceThumbFinger < contactThreshold {
                detectedContactTime = currentTime
                
                switch finger {
                case .indexFingerTip:
                    updateContacts(for: handSide, index: true, middle: false, ring: false)
                    break;
                case .middleFingerTip:
                    updateContacts(for: handSide, index: false, middle: true, ring: false)
                    break;
                case .ringFingerTip:
                    updateContacts(for: handSide, index: false, middle: false, ring: true)
                    break;
                default:
                    break
                }
            }
            if isContactFlagActive(for: handSide, finger: finger) &&
                distanceFingerDestination < destinationThreshold &&
                (currentTime - detectedContactTime) < 0.025 {
                resetState()
                return true
            }
        }
        return false
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
    
    /// Helper: Retrieve the current state for a given finger.
    private func updateContacts(for handSide: String, index: Bool, middle: Bool, ring: Bool) {
        if handSide == "left" {
            leftContactIndex = index
            leftContactMiddle = middle
            leftContactRing = ring
            rightContactIndex = false
            rightContactMiddle = false
            rightContactRing = false
        } else {
            rightContactIndex = index
            rightContactMiddle = middle
            rightContactRing = ring
            leftContactIndex = false
            leftContactMiddle = false
            leftContactRing = false
        }
    }
    
    private func isContactFlagActive(for handSide: String, finger: HandSkeleton.JointName) -> Bool {
        switch finger {
        case .indexFingerTip:
            return handSide == "left" ? leftContactIndex : rightContactIndex
        case .middleFingerTip:
            return handSide == "left" ? leftContactMiddle : rightContactMiddle
        case .ringFingerTip:
            return handSide == "left" ? leftContactRing : rightContactRing
        default:
            return false
        }
    }
    

    private func resetState() {
        
        leftContactRing = false
        leftContactIndex = false
        leftContactMiddle = false
        rightContactRing = false
        rightContactIndex = false
        rightContactMiddle = false
    }
}
