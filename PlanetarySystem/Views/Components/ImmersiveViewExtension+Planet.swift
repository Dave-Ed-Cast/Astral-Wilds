//
//  ImmersiveViewExtension+Planet.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 08/11/24.
//

import SwiftUI
import RealityKit

extension ImmersiveView {
    
    func movePlanet(entity: Entity) {
                
        let oneMinuteSpeed: Float = 2.0
        let threeMinutesSpeed: Float = 0.8
                
        let velocity = (duration == 0) ? oneMinuteSpeed : threeMinutesSpeed
        
        let updateForMovement: TimeInterval = 1.0 / 60.0
        let frameMovement = TimeInterval(velocity) * updateForMovement
        
        planetTimer = Timer.scheduledTimer(withTimeInterval: updateForMovement, repeats: true) { timer in
            
            entity.position.z += Float(frameMovement)
            
            let rotationAngle = Float(0.5)
            let rotationDirection = Float(-1.0)
            entity.transform.rotation *= simd_quatf(
                angle: (rotationDirection * rotationAngle) + 0.01,
                axis: [0, entity.position.y, 0]
            )
        }
    }
}
