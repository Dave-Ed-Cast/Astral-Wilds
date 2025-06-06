//
//  Parameters.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 21/12/24.
//

import ARKit
import SwiftUI

/// A class holding the state to allow gesture recognition.
@Observable
final class GestureRecognizer {
    
    @MainActor static let shared = GestureRecognizer()
    
    /// A snap gesture is a dynamic one, meaning that we have to use at least
    /// two update cycles to detect if a snap occurred. Hence, the enum.
    private enum SnapState {
        case idle
        case candidate
        case snap
    }
    
    private var state: SnapState = .idle
    
    private var candidateTimestamp: TimeInterval?
    private var candidateHand: Chirality? = nil
    
    //constants for snap
    private let maxSnapDuration: TimeInterval = 0.012
    private let angleThreshold: Float = 35.0
    
    /// The variable detecting a snap (true when `thanosSnap` detects one)
    var didThanosSnap = false
    
    private init() {}
    
    //MARK: Public functions
    
    /// Detects if the user snaps their fingers.
    ///
    /// This is used to allow the user to dismiss immersive spaces interactively
    /// through 3D math and fingers local positioning
    ///
    /// - Parameters:
    ///   - left: Left hand anchor update
    ///   - right: Right hand anchor update
    func thanosSnap(left: HandAnchor?, right: HandAnchor?) {
        guard let left = left, left.chirality == .left,
              let right = right, right.chirality == .right,
              let leftSkeleton = left.handSkeleton,
              let rightSkeleton = right.handSkeleton else {
            reset()
            return
        }

        let now = CACurrentMediaTime()

        switch state {
        case .idle: detectCandidateHand(leftSkeleton, rightSkeleton, time: now)
        case .candidate: validateSnapGesture(time: now, leftSkeleton, rightSkeleton)
        case .snap: reset()
        }
    }
    
    func resetSnapState() {
        if didThanosSnap {
            didThanosSnap = false
            reset()
        }
    }
    
    //MARK: Private functions
    
    /// Detects if the hand is a candidate.
    ///
    /// - Parameters:
    ///   - leftSkeleton: The left hand skeleton
    ///   - rightSkeleton: the right hand skeleton
    ///   - time: The time at which a candidate has been found.
    private func detectCandidateHand(_ leftSkeleton: HandSkeleton, _ rightSkeleton: HandSkeleton, time: TimeInterval) {
        
        let leftThumbTip = leftSkeleton.thumbTipTransform.position
        let rightThumbTip = rightSkeleton.thumbTipTransform.position
        
        let leftMiddleTip = leftSkeleton.middleTipTransform.position
        let rightMiddleTip = rightSkeleton.middleTipTransform.position
        
        let leftDistance = simd_distance(leftThumbTip, leftMiddleTip)
        let rightDistance = simd_distance(rightThumbTip, rightMiddleTip)

        if leftDistance < 0.025 {
            print("Candidate detected on LEFT hand")
            state = .candidate
            candidateTimestamp = time
            candidateHand = .left
        } else if rightDistance < 0.025 {
            print("Candidate detected on RIGHT hand")
            state = .candidate
            candidateTimestamp = time
            candidateHand = .right
        } else {
            print("No contact yet")
        }
    }
    
    /// Veerifies if the candidate hand is gonna be doing a snap gesture.
    ///
    /// - Parameters:
    ///   - time: The time in which a candidate was found earlier
    ///   - leftSkeleton: The left hand skeleton
    ///   - rightSkeleton: The right hand skeleton
    private func validateSnapGesture(time: TimeInterval, _ leftSkeleton: HandSkeleton, _ rightSkeleton: HandSkeleton) {
        guard let start = candidateTimestamp, let candidateHand = candidateHand else {
            reset()
            return
        }

        let elapsed = time - start
        let skeleton = (candidateHand == .left) ? leftSkeleton : rightSkeleton
        let thumb = skeleton.thumbTipTransform.position
        let middle = skeleton.middleTipTransform.position
        let angle = thumb.horizontalAngle(to: middle)

        print("Elapsed: \(elapsed * 1000) ms")
        print("Angle on \(candidateHand): \(angle)°")

        if elapsed <= maxSnapDuration {
            if angle < angleThreshold { confirmSnap(on: candidateHand) }
            else { print("Angle too wide. Gesture invalid.") }
            
        } else {
            print("Timeout — gesture not completed.")
            reset()
        }
    }
    
    /// Confirms that a snap has been detected
    /// - Parameter hand: The hand that snapped
    private func confirmSnap(on hand: Chirality) {
        print("Snap detected on \(hand) hand")
        state = .snap
        didThanosSnap = true
    }
    
    /// Resets the needed variables for gestures
    private func reset() {
        state = .idle
        candidateTimestamp = nil
        candidateHand = nil
    }
    
}
