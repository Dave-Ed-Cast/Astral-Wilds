//
//  Parameters.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 21/12/24.
//

import ARKit
import SwiftUI

/// A model that contains up-to-date hand coordinate information.
@MainActor @Observable
final class GestureModel: Sendable {
    
    private let session = ARKitSession()
    private var handTracking = HandTrackingProvider()
    
    private var latestHandTracking: HandsUpdates = .init()
    
    private var leftContactIndex: Bool = false
    private var leftContactMiddle: Bool = false
    private var leftContactRing: Bool = false
    private var rightContactIndex: Bool = false
    private var rightContactMiddle: Bool = false
    private var rightContactRing: Bool = false
        
    private var detectedContactTime: TimeInterval = 0
    private var elapsedTime: TimeInterval = 0
    private var lastLogTime: TimeInterval = 0
    private let logThrottleInterval: TimeInterval = 0.5
    
    fileprivate struct HandsUpdates {
        var left: HandAnchor?
        var right: HandAnchor?
        
        init() {
            self.left = nil
            self.right = nil
        }
    }
    
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
        
        let contactThreshold: Float = 0.011
        let destinationThreshold: Float = 0.08
        
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
            
            if shouldLog() {
                print("Phase 1: \(handSide) \(finger) touched.")
            }
        }
        if isContactFlagActive(for: handSide, finger: finger) &&
            distanceFingerDestination < destinationThreshold &&
            (currentTime - detectedContactTime) < 0.15 {
            resetState()
            print("Phase 2: Snap gesture detected with \(finger).")
            return true
        }
        
        return false
    }
    
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
        if shouldLog() {
            print("Gesture state reset.")
        }
    }
    
    private func shouldLog() -> Bool {
        let currentTime = Date().timeIntervalSince1970
        if currentTime - lastLogTime > logThrottleInterval {
            lastLogTime = currentTime
            return true
        }
        return false
    }
    
}

