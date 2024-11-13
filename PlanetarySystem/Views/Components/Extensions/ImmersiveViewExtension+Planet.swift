//
//  ImmersiveViewExtension+Planet.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 08/11/24.
//

import SwiftUI
import RealityKit

extension ImmersiveView {
    
    /// Moves the planet in the immersive travel
    /// - Parameter entity: The entity to be moved (the planet)
    func movePlanet(_ entity: Entity) {
                
        let oneMinuteSpeed: Float = 2.39
        let threeMinutesSpeed: Float = oneMinuteSpeed / 3.0
                
        let velocity = (duration == 0) ? oneMinuteSpeed : threeMinutesSpeed
        
        let updateForMovement: TimeInterval = 1.0 / 90.0
        let frameMovement = TimeInterval(velocity) * updateForMovement
        
        planetTimer = Timer.scheduledTimer(withTimeInterval: updateForMovement, repeats: true) { timer in
            
            entity.position.z += Float(frameMovement)
            
            let rotationAngle = Float(0.0001)
            let rotationDirection = Float(-1.0)
            entity.transform.rotation *= simd_quatf(
                angle: rotationDirection * rotationAngle,
                axis: [0, entity.position.y, 0]
            )
            
            print(entity.position.z)
        }
    }
}
