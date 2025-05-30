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
    
    private enum SnapState {
        case idle
        case candidate
        case snap
    }
    
    private var state: SnapState = .idle
    private var candidateTimestamp: TimeInterval?
    private var candidateHand: Chirality? = nil
    private let maxSnapDuration: TimeInterval = 0.012
    private let angleThreshold: Float = 35.0
    
    /// The variable detecting a snap (true when `thanosSnap` detects one)
    var didThanosSnap = false
    
    private init() {}
    
    /// Detects if the user snaps their fingers.
    ///
    /// This is used to allow the user to dismiss immersive spaces interactively
    /// through 3D math and fingers loca positioning
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
        case .idle:
            detectCandidateHand(leftSkeleton, rightSkeleton, time: now)

        case .candidate:
            validateSnapGesture(time: now, leftSkeleton, rightSkeleton)

        case .snap:
            print("Snap complete. Resetting state.")
            reset()
        }
    }
    
    private func detectCandidateHand(_ leftSkeleton: HandSkeleton, _ rightSkeleton: HandSkeleton, time: TimeInterval) {
        let leftDistance = simd_distance(leftSkeleton.thumbTipTransform.position, leftSkeleton.middleTipTransform.position)
        let rightDistance = simd_distance(rightSkeleton.thumbTipTransform.position, rightSkeleton.middleTipTransform.position)

        if leftDistance < 0.025 {
            print("Candidate detected on LEFT hand.")
            state = .candidate
            candidateTimestamp = time
            candidateHand = .left
        } else if rightDistance < 0.025 {
            print("Candidate detected on RIGHT hand.")
            state = .candidate
            candidateTimestamp = time
            candidateHand = .right
        }
    }

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

        print("🕒 Elapsed: \(elapsed * 1000) ms")
        print("📐 Angle on \(candidateHand): \(angle)°")

        if elapsed <= maxSnapDuration {
            if angle < angleThreshold { confirmSnap(on: candidateHand) }
            else { print("📉 Angle too wide. Gesture invalid.") }
            
        } else {
            print("⌛ Timeout — gesture not completed.")
            reset()
        }
    }

    private func confirmSnap(on hand: Chirality) {
        print("Snap detected on \(hand) hand")
        state = .snap
        didThanosSnap = true
    }
    
    func resetSnapState() {
        if didThanosSnap {
            didThanosSnap = false
            reset()
        }
    }
    
    private func reset() {
        state = .idle
        candidateTimestamp = nil
        candidateHand = nil
    }
}
