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
        
        let oneMinute = 60
        let oneMinuteSpeed: Float = 2.0
        
        let threeMinutes = 180
        let threeMinutesSpeed: Float = 0.8
        
        let selectedDuration = (duration == 0 ? oneMinute : threeMinutes)
        
        let velocity = (selectedDuration == oneMinute) ? oneMinuteSpeed : threeMinutesSpeed
        
        let updateForMovement: TimeInterval = 1.0 / 60.0
        let frameMovement = TimeInterval(velocity) * updateForMovement
        
        planetTimer = Timer.scheduledTimer(withTimeInterval: updateForMovement, repeats: true) { timer in
            
            entity.position.z += Float(frameMovement)
            print(entity.position.z)
            
            let rotationAngle = Float(0.005)
            let rotationDirection = Float(-1.0)
            entity.transform.rotation *= simd_quatf(
                angle: rotationDirection * rotationAngle,
                axis: [0, entity.position.y, 0]
            )
        }
    }
}
