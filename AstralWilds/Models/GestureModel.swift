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
    
    fileprivate var lastSnapTimestamp: TimeInterval = 0
    
    fileprivate var currentSession: ARKitSession = .init()
    fileprivate let session = ARKitSession()
    fileprivate var handTracking = HandTrackingProvider()
    
    fileprivate var fingerStates: [String: FingerState] = [:]
    fileprivate var latestHandTracking: HandsUpdates = .init(left: nil, right: nil)
    
    internal var isSnapGestureActivated: Bool = false
    
    internal struct FingerState {
        var previousThumbPosition: SIMD3<Float>?
        var previousFingerPosition: SIMD3<Float>?
        var contact: Bool = false
    }
    
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
                
                // Update the latest hand tracking state
                if anchor.chirality == .left {
                    latestHandTracking.left = anchor
                } else if anchor.chirality == .right {
                    latestHandTracking.right = anchor
                }
                
                // Process snapping gesture detection
                Task.detached { [self] in
                    // Check for snapping gestures for both hands and fingers
                    let leftSnapMiddle = await snapGestureActivated(for: "left", finger: .middleFingerTip)
                    let leftSnapRing = await snapGestureActivated(for: "left", finger: .ringFingerTip)
                    let leftSnapIndex = await snapGestureActivated(for: "left", finger: .indexFingerTip)
                    
                    let rightSnapMiddle = await snapGestureActivated(for: "right", finger: .middleFingerTip)
                    let rightSnapRing = await snapGestureActivated(for: "right", finger: .ringFingerTip)
                    let rightSnapIndex = await snapGestureActivated(for: "right", finger: .indexFingerTip)
                    
                    // Check if any snap occurred
                    let anySnap = leftSnapMiddle || leftSnapRing || leftSnapIndex || rightSnapMiddle || rightSnapRing || rightSnapIndex
                    if anySnap {
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
    
    /// Detects a snapping gesture starting from the thumb and a specified finger (index, middle, or ring) of the specified hand.
    /// - Parameters:
    ///   - handSide: Specify "left" or "right" to detect snap gestures for the respective hand.
    ///   - finger: The specific finger to check for the snap gesture.
    /// - Returns: True if the user snapped with the specified finger of the specified hand.
    fileprivate func snapGestureActivated(for handSide: String, finger: HandSkeleton.JointName) async -> Bool {
        guard let handAnchor = (handSide == "left" ? latestHandTracking.left : latestHandTracking.right),
              handAnchor.isTracked else {
            print("\(handSide.capitalized) hand anchor is not tracked.")
            return false
        }
        
        guard let handSkeleton = handAnchor.handSkeleton else {
            print("\(handSide.capitalized) hand skeleton not available.")
            return false
        }
        
        let fingerKey = "\(handSide)_\(finger)"
        if fingerStates[fingerKey] == nil {
            fingerStates[fingerKey] = FingerState()
        }
        guard var state = fingerStates[fingerKey] else { return false }
        
        let thumbPosition = matrix_multiply(
            handAnchor.originFromAnchorTransform,
            handSkeleton.joint(.thumbTip).anchorFromJointTransform
        ).columns.3.xyz
        
        let fingerPosition = matrix_multiply(
            handAnchor.originFromAnchorTransform,
            handSkeleton.joint(finger).anchorFromJointTransform
        ).columns.3.xyz
        
        let distance = simd_distance(thumbPosition, fingerPosition)
        
        if let prevThumb = state.previousThumbPosition, let prevFinger = state.previousFingerPosition {
            let thumbDirection = simd_normalize(thumbPosition - prevThumb)
            let fingerDirection = simd_normalize(fingerPosition - prevFinger)
            let dotProduct = simd_dot(thumbDirection, fingerDirection)
            let angleInDegrees = acos(dotProduct) * (180.0 / .pi)
            
            let contactThreshold: Float = 0.02
            let releaseThreshold: Float = 0.06
            let maxThreshold: Float = 0.12
            let minSnapAngle: Float = 5.0
            let maxSnapAngle: Float = 20.0
            
            let currentTime = Date().timeIntervalSince1970
            
            if distance < contactThreshold {
                state.contact = true
                lastSnapTimestamp = currentTime
                print("\(handSide.capitalized) wasInContact with \(finger): \(state.contact)")
            }
            
            let validDistance = distance > releaseThreshold && distance < maxThreshold
            let validAngle = angleInDegrees >= minSnapAngle && angleInDegrees <= maxSnapAngle
            let withinTimeframe = currentTime - lastSnapTimestamp <= 0.25
            
            if state.contact && validDistance && validAngle && withinTimeframe {
                let metacarpalJointName: HandSkeleton.JointName
                switch finger {
                case .indexFingerTip: metacarpalJointName = .indexFingerMetacarpal
                case .middleFingerTip: metacarpalJointName = .middleFingerMetacarpal
                case .ringFingerTip: metacarpalJointName = .ringFingerMetacarpal
                default: return false
                }
                
                let metacarpalPosition = matrix_multiply(
                    handAnchor.originFromAnchorTransform,
                    handSkeleton.joint(metacarpalJointName).anchorFromJointTransform
                ).columns.3.xyz
                
                let thumbToMetacarpalDir = simd_normalize(thumbPosition - metacarpalPosition)
                let thanosSnap = simd_dot(thumbDirection, thumbToMetacarpalDir)
                
                print("The thanos snap distance is: \(thanosSnap), with angle: \(angleInDegrees)")
                
                if thanosSnap > 0.4 {
                    print("\(handSide.capitalized) hand snapped with \(finger)!")
                    resetState()
                    return true
                }
            }
            
            // Reset contact if timeframe has elapsed
            if !withinTimeframe {
                state.contact = false
            }
        }
        
        state.previousThumbPosition = thumbPosition
        state.previousFingerPosition = fingerPosition
        fingerStates[fingerKey] = state
        return false
    }
    
    fileprivate func resetState() {
        fingerStates.removeAll()
        print("All states have been reset.")
    }
}
