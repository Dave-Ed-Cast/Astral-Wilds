//
//  Parameters.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 21/12/24.
//

import ARKit
import SwiftUI

@Observable
final class GestureRecognizer {
    
    @MainActor static let shared = GestureRecognizer()
    
    private enum snapState { case idle, candidate, snap }
    
    private var state: snapState = .idle
    private var candidateTimestamp: TimeInterval?
    private let maxSnapDuration: TimeInterval = 0.015
    private let angleThreshold: Float = 30
    
    var didThanosSnap = false
    
    private init() {}
    
    func thanosSnap(left: HandAnchor?, right: HandAnchor?) {
        guard let left = left, left.chirality == .left,
              let right = right, right.chirality == .right,
              let leftSkeleton = left.handSkeleton,
              let rightSkeleton = right.handSkeleton
        else { return }
        
        let thumbLocal = leftSkeleton.thumbTipTransform.position
        let middleLocal = leftSkeleton.middleTipTransform.position
        
        let distance = simd_distance(thumbLocal, middleLocal)
        let now = CACurrentMediaTime()
        
        switch state {
        case .idle:
            if distance < 0.025 {
                print("Candidate detected. Distance below threshold.")
                state = .candidate
                candidateTimestamp = now
            }
            
        case .candidate:
            let elapsed = now - (candidateTimestamp ?? now)
            let angle = thumbLocal.horizontalAngle(to: middleLocal)
            
            print("🕒 Elapsed: \(elapsed * 1000) ms")
            print("📐 Horizontal Angle: \(angle)°")
            
            if elapsed <= maxSnapDuration {
                if angle < angleThreshold {
                    print("✅ Snap detected!")
                    state = .snap
                    didThanosSnap = true
                    
                } else { print("Not good :(") }
            } else {
                print("⌛ Timeout — gesture not completed.")
                state = .idle
            }
            
        case .snap:
            print("Snap complete. Resetting state.")
            state = .idle
            candidateTimestamp = nil
        }
    }
    
    func resetSnapState() { didThanosSnap ? didThanosSnap = false : () }
}
