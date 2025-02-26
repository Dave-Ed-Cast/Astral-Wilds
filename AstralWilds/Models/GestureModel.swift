//
//  Parameters.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 21/12/24.
//

import ARKit
import SwiftUI

/// A model that contains up-to-date hand coordinate information.
/// In this class, custom gestures are implemented.
///
/// Supported custom gestures available: `Snap`
///  -  This is built with `accessibility` in mind. Humans can snap with three possible fingers and two possible hands.
///     Up to `six` possible cases, all of them are consistently handled.
@MainActor @Observable
final class GestureModel {
    
    private let session = ARKitSession()
    private var handTracking = HandTrackingProvider()
    
    private var latestHandTracking: HandsUpdates = .init()
    
    /// These variables hold the information of the finger that was last in contact for the `Snap` gesture
    private var leftContactIndex: Bool = false
    private var leftContactMiddle: Bool = false
    private var leftContactRing: Bool = false
    private var rightContactIndex: Bool = false
    private var rightContactMiddle: Bool = false
    private var rightContactRing: Bool = false
    
    /// Time variable to understand if a `snap`  happened
    ///
    /// A 2021 California study found out a snap occurs in 7 ms.
    /// In thus Swift 6 app, due to concurrency, we use 20 ms as a safe threshold to confirm a snap, based on testing.
    private var detectedContactTime: TimeInterval = 0
    
    /// Holds the information of the last update for the hand
    private struct HandsUpdates {
        var left: HandAnchor?
        var right: HandAnchor?
        
        init() {
            self.left = nil
            self.right = nil
        }
    }
    
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
                
                // Update the latest hand tracking state
                await MainActor.run {
                    if anchor.chirality == .left {
                        latestHandTracking.left = anchor
                    } else if anchor.chirality == .right {
                        latestHandTracking.right = anchor
                    }
                }
                
                // Process snapping gesture detection
                Task.detached { [self] in
                    
                    let leftSnapMiddle = await thanosSnap(for: "left", finger: .middleFingerTip)
                    let leftSnapRing = await thanosSnap(for: "left", finger: .ringFingerTip)
                    let leftSnapIndex = await thanosSnap(for: "left", finger: .indexFingerTip)
                    
                    let rightSnapMiddle = await thanosSnap(for: "right", finger: .middleFingerTip)
                    let rightSnapRing = await thanosSnap(for: "right", finger: .ringFingerTip)
                    let rightSnapIndex = await thanosSnap(for: "right", finger: .indexFingerTip)
                    
                    let anySnap = leftSnapMiddle || leftSnapRing || leftSnapIndex || rightSnapMiddle || rightSnapRing || rightSnapIndex
                    
                    if anySnap {
                        await MainActor.run {
                            didThanosSnap = true
                        }
                        try? await Task.sleep(nanoseconds: 500_000_000)
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
    
    /// Detects a snapping gesture starting from the thumb and a specified finger (index, middle, or ring) of the specified hand.
    ///
    /// ### The building of this function is still in the process of optimisation. However, the current state grants robust and consistent usage
    ///
    /// - Parameters:
    ///   - handSide: Specify "left" or "right" to detect snap gestures for the respective hand.
    ///   - finger: The specific finger to check for the snap gesture.
    /// - Returns: True if the user snapped with the specified finger of the specified hand.
    private func thanosSnap(for handSide: String, finger: HandSkeleton.JointName) -> Bool {
        guard let handAnchor = (handSide == "left" ? latestHandTracking.left : latestHandTracking.right),
              let handSkeleton = handAnchor.handSkeleton,
              handAnchor.isTracked else {
            resetState()
            return false
        }
        
        let origin = handAnchor.originFromAnchorTransform
        let joint = handSkeleton.joint
        
        let thumbAnchor = joint(.thumbTip).anchorFromJointTransform
        let fingerAnchor = joint(finger).anchorFromJointTransform
        let thumbKnuckleAnchor = joint(.thumbKnuckle).anchorFromJointTransform
        
        let thumbPosition = matrix_multiply(origin, thumbAnchor).columns.3.xyz
        let fingerPosition = matrix_multiply(origin, fingerAnchor).columns.3.xyz
        let thumbKnucklePosition = matrix_multiply(origin, thumbKnuckleAnchor).columns.3.xyz
        
        let distanceThumbFinger = simd_precise_distance(thumbPosition, fingerPosition)
        let distanceFingerDestination = simd_precise_distance(fingerPosition, thumbKnucklePosition)
        
        let contactThreshold: Float = finger == .middleFingerTip ? 0.02 : 0.01
        let destinationThreshold: Float = 0.07
        
        let currentTime = Date().timeIntervalSince1970
        
        if distanceThumbFinger < contactThreshold {
            detectedContactTime = currentTime
            
            switch finger {
            case .indexFingerTip:
                updateContacts(for: handSide, index: true, middle: false, ring: false)
            case .middleFingerTip:
                updateContacts(for: handSide, index: false, middle: true, ring: false)
            case .ringFingerTip:
                updateContacts(for: handSide, index: false, middle: false, ring: true)
            default:
                break
            }
        }
        
        if isContactFlagActive(for: handSide, finger: finger) &&
            distanceFingerDestination < destinationThreshold &&
            (currentTime - detectedContactTime) < 0.02 {
            resetState()
            return true
        }
        return false
    }
    
    /// Updates the state of the fingers that have been in contact
    ///
    /// This is an helper function for the `thanosSnap`. It helps in understanding which finger touched and should be considered for the snapping motion
    /// - Parameters:
    ///   - handSide: The hand (left or right)
    ///   - index: State of the index (if it was the one in contact or not)
    ///   - middle: State of the middle (if it was the one in contact or not)
    ///   - ring: State of the ring (if it was the one in contact or not)
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

