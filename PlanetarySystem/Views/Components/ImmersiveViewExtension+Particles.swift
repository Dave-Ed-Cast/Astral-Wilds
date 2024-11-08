//
//  ImmersiveViewExtension.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 08/11/24.
//

import SwiftUI
import RealityKit

extension ImmersiveView {
    
    func createNewParticle(entity: Entity, environment: EnvironmentResource, content: RealityViewContent) {
        
        let newParticleInterval: TimeInterval = 0.2
        
        particleTimer = Timer.scheduledTimer(withTimeInterval: newParticleInterval, repeats: true) { _ in
            
            guard spawnParticle else { return }
            let particleEntity = content.createParticle()
            
            particleEntity.configureLighting(resource: environment, withShadow: true, for: entity)
            particles.append(particleEntity)
            content.add(particleEntity)
        }
    }
    
    func moveParticles() {
        
        let updateInterval: TimeInterval = 1.0 / 90.0
        let particleSpeed: Float = 0.015
        
        moveParticleTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            
            for particleEntity in particles {
                particleEntity.position.z += particleSpeed
                
                if particleEntity.position.z > 23 {
                    particleEntity.removeFromParent()
                    
                    if let index = particles.firstIndex(of: particleEntity) {
                        particles.remove(at: index)
                    }
                }
            }
        }
    }
    
    func stopParticles() {
        particleTimer?.invalidate()
        particleTimer = nil
        spawnParticle = false
    }
}
