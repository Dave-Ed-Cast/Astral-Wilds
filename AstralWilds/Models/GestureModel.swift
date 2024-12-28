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
    
    internal var handTracking = HandTrackingProvider()
    internal var latestHandTracking: HandsUpdates = .init(left: nil, right: nil)
    
    internal let session = ARKitSession()
    
    internal struct HandsUpdates {
        var left: HandAnchor?
        var right: HandAnchor?
    }
    
    var isSnapGestureActivated: Bool = false
    
    /// Start the hand tracking session.
    internal func start() async {
        do {
            if HandTrackingProvider.isSupported {
                try await session.run([handTracking])
                print("ARKitSession starting.")
            }
        } catch {
            print("ARKitSession error:", error)
        }
    }
    
    /// Stop the hand tracking session.
    internal func stop() async {
        if HandTrackingProvider.isSupported {
            session.stop()
            print("ARKitSession stopped.")
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
                    let snapGestureDetected = await snapGestureActivated()
                    if snapGestureDetected {
                        await MainActor.run {
                            isSnapGestureActivated = true
                        }
                        try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
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
    
    /// Detects a snapping gesture starting from the middle finger of the left hand only.
    /// - Returns: True if the user snapped.
    fileprivate func snapGestureActivated() -> Bool {
        guard let leftHandAnchor = latestHandTracking.left,
              leftHandAnchor.isTracked else {
            print("Left hand anchor is not tracked.")
            return false
        }
        let leftHandThumb = leftHandAnchor.handSkeleton!.joint(.thumbTip)
        let leftHandMiddle = leftHandAnchor.handSkeleton!.joint(.middleFingerTip)
        
        guard leftHandThumb.isTracked, leftHandMiddle.isTracked else {
            print("Thumb or middle finger not tracked.")
            resetState()
            return false
        }
        
        let leftThumbPosition = matrix_multiply(
            leftHandAnchor.originFromAnchorTransform, leftHandThumb.anchorFromJointTransform
        ).columns.3.xyz
        
        let leftMiddleFingerPosition = matrix_multiply(
            leftHandAnchor.originFromAnchorTransform, leftHandMiddle.anchorFromJointTransform
        ).columns.3.xyz
        
        let distance = simd_distance(leftThumbPosition, leftMiddleFingerPosition)
        
        if let prevThumb = previousThumbPosition, let prevMiddle = previousMiddleFingerPosition {
            let thumbDirection = simd_normalize(leftThumbPosition - prevThumb)
            let middleDirection = simd_normalize(leftMiddleFingerPosition - prevMiddle)
            
            let dotProduct = simd_dot(thumbDirection, middleDirection)
            let angle = acos(dotProduct)
            let angleInDegrees = angle * (180.0 / .pi)
            
            let contactThreshold: Float = 0.01
            let releaseThreshold: Float = 0.05
            let maxThreshold: Float = 0.1
            
            let minSnapAngle: Float = 2.0
            let maxSnapAngle: Float = 15.0
            
            if distance < contactThreshold {
                contact = true
                print("wasInContact: \(contact)")
            }
            
            let fingerDistance = (distance > releaseThreshold && distance < maxThreshold)
            let fingerAngle = angleInDegrees >= minSnapAngle && angleInDegrees <= maxSnapAngle
            
            let middleFingerMetacarpal = leftHandAnchor.handSkeleton!.joint(.middleFingerMetacarpal).anchorFromJointTransform.columns.3.xyz
            
            if contact && fingerDistance && fingerAngle {
                
                let thumbToMetacarpalDistance = simd_normalize(leftThumbPosition - middleFingerMetacarpal)
                let thanosSnap = simd_dot(thumbDirection, thumbToMetacarpalDistance)
                
                if thanosSnap > 0.25 {
                    print("Thanos snapped!")
                    resetState()
                    return true
                }
            }
        }
        
        previousThumbPosition = leftThumbPosition
        previousMiddleFingerPosition = leftMiddleFingerPosition
        
        return false
    }
    
    fileprivate func resetState() {
        contact = false
        previousThumbPosition = nil
        previousMiddleFingerPosition = nil
    }
}
