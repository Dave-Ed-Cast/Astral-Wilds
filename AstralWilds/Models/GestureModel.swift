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
class GestureModel: Sendable {
    
    private var wasInContact: Bool = false
    private var previousTimestamp: TimeInterval?
    
    private var previousThumbPosition: SIMD3<Float>?
    private var previousMiddleFingerPosition: SIMD3<Float>?
    
    let session = ARKitSession()
    
    var handTracking = HandTrackingProvider()
    var latestHandTracking: HandsUpdates = .init(left: nil, right: nil)
    
    var isSnapGestureActivated: Bool = false
    
    struct HandsUpdates {
        var left: HandAnchor?
        var right: HandAnchor?
    }
    
    func start() async {
        do {
            if HandTrackingProvider.isSupported {
                print("ARKitSession starting.")
                try await session.run([handTracking])
            }
        } catch {
            print("ARKitSession error:", error)
        }
        
        Task { await checkSnapGesture() }
    }
    
    func stop() async {
        if HandTrackingProvider.isSupported {
            print("ARKitSession stopped.")
            session.stop()
        }
    }
    
    func publishHandTrackingUpdates() async {
        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .updated:
                let anchor = update.anchor
                
                // Publish updates only if the hand and the relevant joints are tracked.
                guard anchor.isTracked else { continue }
                
                // Update left hand info.
                if anchor.chirality == .left {
                    latestHandTracking.left = anchor
                } else if anchor.chirality == .right { // Update right hand info.
                    latestHandTracking.right = anchor
                }
            default:
                break
            }
        }
    }
    
    func checkSnapGesture() async {
        while true {
            if snapGestureActivated() {
                isSnapGestureActivated = true
                try? await Task.sleep(nanoseconds: 1 * 1_000_000_000)
                isSnapGestureActivated = false
            }
            await Task.yield()
        }
    }
    
    func snapGestureActivated() -> Bool {
        guard let leftHandAnchor = latestHandTracking.left,
              leftHandAnchor.isTracked else {
            print("Left hand anchor is not tracked.")
            resetState()
            return false
        }
        
        guard let leftHandThumb = leftHandAnchor.handSkeleton?.joint(.thumbTip),
              let leftHandMiddle = leftHandAnchor.handSkeleton?.joint(.middleFingerTip),
              leftHandThumb.isTracked, leftHandMiddle.isTracked else {
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
            let minSnapAngle: Float = 2.0
            let maxSnapAngle: Float = 15.0
            
            if distance < contactThreshold {
                wasInContact = true
                print("true")
            }
            
            let maxThreshold: Float = 0.1
            
            if wasInContact && (distance > releaseThreshold && distance < maxThreshold) &&
                angleInDegrees >= minSnapAngle && angleInDegrees <= maxSnapAngle {
                
                let thumbToPalmDirection = simd_normalize(leftThumbPosition - leftHandAnchor.handSkeleton!.joint(.middleFingerMetacarpal).anchorFromJointTransform.columns.3.xyz)
                let thumbSnapMotion = simd_dot(thumbDirection, thumbToPalmDirection)
                
                if thumbSnapMotion > 0.25 {
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
    
    func resetState() {
        wasInContact = false
        previousThumbPosition = nil
        previousMiddleFingerPosition = nil
    }
}
