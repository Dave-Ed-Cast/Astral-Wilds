//
//  Parameters.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 21/12/24.
//

import ARKit
import SwiftUI

/// A model that contains up-to-date hand coordinate information.
/// This class also holds custom gestures.
///
/// Supported custom gestures available: `Snap`
///  -  This is built with `accessibility` in mind. Humans can snap with three possible fingers and two possible hands.
///     Up to `six` possible cases, all of them are consistently handled.
@MainActor @Observable
final class GestureModel {
    
    /// Varaibles for the hand tracking
    private let session = ARKitSession()
    private var handTracking = HandTrackingProvider()
    
    /// The variable holding the latest tracked hand
    private var latestHandTracking: HandsUpdates = .init()
    
    /// Time variable to understand if a `snap`  happened
    ///
    /// A 2021 California study found out a snap occurs in 7 ms.
    /// Due to concurrency, it's safer to use a 7.5ms threshold to confirm a snap, based on testing.
    private var detectedContactTime: TimeInterval = 0
    
    /// Holds the latest hand anchor information for the hands.
    private struct HandsUpdates {
        var left: HandAnchor?
        var right: HandAnchor?
        
        init() {
            self.left = nil
            self.right = nil
        }
    }
    
    private var contact: Bool = false
    private var previousThumbPosition: SIMD3<Float>? = nil
    private var previousTime: TimeInterval? = nil
    
    /// Use this supervisor to detect if a snap occurs. It will be true once the snap has occurred.
    var didThanosSnap: Bool = false
    
    var rootEntity: Entity? = nil
    
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
                
                //If tracked, update the latest state
                
                
                //MARK: Il bug ha a che fare che snappato una volta, non snappa più
                Task.detached { [self] in
                    
                    let snap = await snapGesture(with: anchor)
                    
                    if snap {
                        await MainActor.run {
                            didThanosSnap = true
                        }
                        try? await Task.sleep(for: .seconds(0.25))
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
    
    
    
}
