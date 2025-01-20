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
    
    
    private var lastLogTime: TimeInterval = 0
    private let logThrottleInterval: TimeInterval = 0.5
    
    private let session = ARKitSession()
    private var handTracking = HandTrackingProvider()
    
    private var fingerState: FingerState = .init()
    fileprivate var latestHandTracking: HandsUpdates = .init()
    
    private var leftContactIndex: Bool = false
    private var leftContactMiddle: Bool = false
    private var leftContactRing: Bool = false
    
    private var rightContactIndex: Bool = false
    private var rightContactMiddle: Bool = false
    private var rightContactRing: Bool = false
    
    private var activeHandSide: String?
    private var activeFinger: HandSkeleton.JointName?
    
    private var detectedContactTime: TimeInterval = 0
    private var generalTime: TimeInterval = Date().timeIntervalSince1970
    private var elapsedTime: TimeInterval = 0
    
    private var fingersThatCanSnap: [HandSkeleton.JointName] = [
        HandSkeleton.JointName.indexFingerTip,
        HandSkeleton.JointName.middleFingerTip,
        HandSkeleton.JointName.ringFingerTip,
    ]
    
    var isSnapGestureActivated: Bool = false
    
    struct FingerState {
        var detectedFinger: HandSkeleton.JointName?
        var detectedHand: String?
        var detectedAnchor: HandAnchor?
        var previousDistance: Float?
        
        fileprivate init() {
            self.detectedFinger = nil
            self.detectedHand = nil
            self.detectedAnchor = nil
            self.previousDistance = nil
        }
    }
    
    fileprivate struct HandsUpdates {
        var left: HandAnchor?
        var right: HandAnchor?
        
        init() {
            self.left = nil
            self.right = nil
        }
    }
    
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
                
//                let rightResult = fingerSnap(handAnchor: latestHandTracking.right!)
                
                // Process snapping gesture detection
                Task.detached { [self] in
                    let leftSnapMiddle = await snapGestureActivated(for: "left", finger: .middleFingerTip)
                    let leftSnapRing = await snapGestureActivated(for: "left", finger: .ringFingerTip)
                    let leftSnapIndex = await snapGestureActivated(for: "left", finger: .indexFingerTip)
                    
                    let rightSnapMiddle = await snapGestureActivated(for: "right", finger: .middleFingerTip)
                    let rightSnapRing = await snapGestureActivated(for: "right", finger: .ringFingerTip)
                    let rightSnapIndex = await snapGestureActivated(for: "right", finger: .indexFingerTip)
                    
                    let anySnap = leftSnapMiddle || leftSnapRing || leftSnapIndex || rightSnapMiddle || rightSnapRing || rightSnapIndex
                    
                    if await anySnap {
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
    fileprivate func snapGestureActivated(for handSide: String, finger: HandSkeleton.JointName) -> Bool {
        guard let handAnchor = (handSide == "left" ? latestHandTracking.left : latestHandTracking.right),
              let handSkeleton = handAnchor.handSkeleton,
              handAnchor.isTracked else {
            resetState()
            return false
        }
        
        let origin = handAnchor.originFromAnchorTransform
        let joint = handSkeleton.joint
        
        let thumbPosition = matrix_multiply(
            origin, joint(.thumbTip).anchorFromJointTransform
        ).columns.3.xyz
        
        let fingerPosition = matrix_multiply(
            origin, joint(finger).anchorFromJointTransform
        ).columns.3.xyz
        
        let thumbKnucklePosition = matrix_multiply(
            origin, joint(.thumbKnuckle).anchorFromJointTransform
        ).columns.3.xyz
        
        let distanceThumbFinger = simd_precise_distance(thumbPosition, fingerPosition)
        let distanceFingerDestination = simd_precise_distance(fingerPosition, thumbKnucklePosition)
        
        let contactThreshold: Float = 0.01
        let destinationThreshold: Float = 0.075
        
        let currentTime = Date().timeIntervalSince1970
        
        if distanceThumbFinger < contactThreshold {
            detectedContactTime = Date().timeIntervalSince1970
            elapsedTime = currentTime - detectedContactTime
            activeHandSide = handSide
            activeFinger = finger

            switch finger {
            case .indexFingerTip:
                if handSide == "left" {
                    leftContactIndex = true
                    rightContactIndex = false
                } else {
                    leftContactIndex = false
                    rightContactIndex = true
                }
               
                leftContactMiddle = false
                leftContactRing = false
                rightContactMiddle = false
                rightContactRing = false
                
            case .middleFingerTip:
                if handSide == "left" {
                    leftContactMiddle = true
                    rightContactMiddle = false
                } else {
                    leftContactMiddle = false
                    rightContactMiddle = true
                }
                
                leftContactIndex = false
                leftContactRing = false
                rightContactIndex = false
                rightContactRing = false
            case .ringFingerTip:
                if handSide == "left" {
                    leftContactRing = true
                    rightContactRing = false
                } else {
                    leftContactRing = false
                    rightContactRing = true
                }
                
                leftContactIndex = false
                leftContactMiddle = false
                rightContactIndex = false
                rightContactMiddle = false
            default: break
            }
            
            if shouldLog() {
                print("Phase 1: \(String(describing: activeHandSide)) \(finger) touched.")
//                print("leftContactIndex: \(leftContactIndex), leftContactMiddle: \(leftContactMiddle), leftContactRing: \(leftContactRing), rightContactIndex: \(rightContactIndex), rightContactMiddle: \(rightContactMiddle), rightContactRing: \(rightContactRing)")
            }
        }
        
        
            
            // Ensure the respective flag for the finger is true before confirming the snap
            let isFingerFlagActive: Bool = {
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
            }()
            
            if isFingerFlagActive && distanceFingerDestination < destinationThreshold && elapsedTime < 0.3 {
                resetState()
                print("Phase 2: Snap gesture detected with \(finger).")
                return true
            }
        
        
        return false
    }
    
    fileprivate func resetState() {
        
        generalTime = 0
        activeHandSide = nil
        activeFinger = nil
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
    
    fileprivate func shouldLog() -> Bool {
        let currentTime = Date().timeIntervalSince1970
        if currentTime - lastLogTime > logThrottleInterval {
            lastLogTime = currentTime
            return true
        }
        return false
    }
    
}

