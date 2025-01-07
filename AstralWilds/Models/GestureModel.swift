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
        
    fileprivate var contact: Bool = false
    fileprivate var previousTimestamp: TimeInterval?
    
    fileprivate var previousThumbPosition: SIMD3<Float>?
    fileprivate var previousMiddleFingerPosition: SIMD3<Float>?
    
    fileprivate var currentSession: ARKitSession = .init()
    fileprivate let session = ARKitSession()
    
    internal var handTracking = HandTrackingProvider()
    internal var latestHandTracking: HandsUpdates = .init(left: nil, right: nil)
    internal var isSnapGestureActivated: Bool = false
    
    internal struct HandsUpdates {
        var left: HandAnchor?
        var right: HandAnchor?
    }
        
    /// Start the hand tracking session.
    internal func startTrackingSession() async {
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
    internal func updateTracking() async {
        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .updated:
                let anchor = update.anchor
                guard anchor.isTracked else { continue }
                
                if anchor.chirality == .left {
                    latestHandTracking.left = anchor
                } else if anchor.chirality == .right {
                    latestHandTracking.right = anchor
                }
                
                Task.detached { [self] in
                    let leftSnap = await snapGestureActivated(for: "left")
                    let rightSnap = await snapGestureActivated(for: "right")
                    
                    if leftSnap || rightSnap {
                        await MainActor.run {
                            isSnapGestureActivated = true
                        }
                        try? await Task.sleep(nanoseconds: 500_000_000)
                        await MainActor.run {
                            isSnapGestureActivated = false
                        }
                    }
                }
                
            default:
                break
            }
        }
    }
    
    /// Detects a snapping gesture starting from the middle finger of the specified hand.
    /// - Parameter handSide: Specify "left" or "right" to detect snap gestures for the respective hand.
    /// - Returns: True if the user snapped with the specified hand.
    fileprivate func snapGestureActivated(for handSide: String) -> Bool {
        guard let handAnchor = (handSide == "left" ? latestHandTracking.left : latestHandTracking.right),
              handAnchor.isTracked else {
            print("\(handSide.capitalized) hand anchor is not tracked.")
            return false
        }
        
        guard let handSkeleton = handAnchor.handSkeleton else {
            print("\(handSide.capitalized) hand skeleton not available.")
            return false
        }
        
        let thumb = handSkeleton.joint(.thumbTip)
        let middleFinger = handSkeleton.joint(.middleFingerTip)
        guard thumb.isTracked, middleFinger.isTracked else {
            print("\(handSide.capitalized) thumb or middle finger not tracked.")
            resetState()
            return false
        }
        
        let thumbPosition = matrix_multiply(handAnchor.originFromAnchorTransform, thumb.anchorFromJointTransform).columns.3.xyz
        let middleFingerPosition = matrix_multiply(handAnchor.originFromAnchorTransform, middleFinger.anchorFromJointTransform).columns.3.xyz
        let distance = simd_distance(thumbPosition, middleFingerPosition)
        
        if let prevThumb = previousThumbPosition, let prevMiddle = previousMiddleFingerPosition {
            let thumbDirection = simd_normalize(thumbPosition - prevThumb)
            let middleDirection = simd_normalize(middleFingerPosition - prevMiddle)
            let dotProduct = simd_dot(thumbDirection, middleDirection)
            let angleInDegrees = acos(dotProduct) * (180.0 / .pi)
            
            let contactThreshold: Float = 0.01
            let releaseThreshold: Float = 0.05
            let maxThreshold: Float = 0.1
            let minSnapAngle: Float = 2.0
            let maxSnapAngle: Float = 15.0
            
            if distance < contactThreshold {
                contact = true
                print("\(handSide.capitalized) wasInContact: \(contact)")
            }
            
            let validDistance = distance > releaseThreshold && distance < maxThreshold
            let validAngle = angleInDegrees >= minSnapAngle && angleInDegrees <= maxSnapAngle
            
            if contact && validDistance && validAngle {
                let metacarpalPosition = matrix_multiply(handAnchor.originFromAnchorTransform, handSkeleton.joint(.middleFingerMetacarpal).anchorFromJointTransform).columns.3.xyz
                let thumbToMetacarpalDir = simd_normalize(thumbPosition - metacarpalPosition)
                let snapStrength = simd_dot(thumbDirection, thumbToMetacarpalDir)
                
                if snapStrength > 0.25 {
                    print("\(handSide.capitalized) hand snapped!")
                    resetState()
                    return true
                }
            }
        }
        
        // Update previous positions
        previousThumbPosition = thumbPosition
        previousMiddleFingerPosition = middleFingerPosition
        return false
    }
    
    fileprivate func resetState() {
        contact = false
        previousThumbPosition = nil
        previousMiddleFingerPosition = nil
    }
}
