//
//  ImmersiveViewExtension.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 08/11/24.
//

import SwiftUI
import RealityKit

extension ImmersiveTravel {
    
//    /// This creates particles for the immersive travel. They are thrown at the player to simulate the voyage
//    /// - Returns: the anchor entity point of where the range of particles should spawn
//    private func createParticle() -> AnchorEntity {
//        
//        let material = SimpleMaterial(color: UIColor(Color("particleColor").opacity(0.1)), isMetallic: false)
//        let mesh = MeshResource.generateSphere(radius: 0.02)
//        
//        let particleEntity = ModelEntity(
//            mesh: mesh,
//            materials: [material]
//        )
//        
//        var randomX: Float
//        var randomY: Float
//        
//        repeat {
//            randomX = Float.random(in: -4...4)
//        } while randomX >= -0.3 && randomX <= 0.3
//        
//        repeat {
//            randomY = Float.random(in: -2...2)
//        } while randomY >= 0.7 && randomY <= 1
//        
//        let anchor = AnchorEntity(world: [randomX, randomY, -25.0])
//        anchor.addChild(particleEntity)
//        
//        return anchor
//    }
//    
//    /// Create new particle element for the immersive travel
//    ///
//    /// - Parameters:
//    ///   - environment: The environment resource for lighting
//    ///   - content: The reality view
//    func createNewParticle(environment: EnvironmentResource, content: RealityViewContent) {
//        
//        let newParticleInterval: TimeInterval = 0.2
//        
//        particleTimer = Timer.scheduledTimer(withTimeInterval: newParticleInterval, repeats: true) { _ in
//            
//            guard currentStep >= 1 else { return }
//            let particleEntity = createParticle()
//            
//            particleEntity.configureLighting(resource: environment, withShadow: true)
//            particles.append(particleEntity)
//            content.add(particleEntity)
//        }
//    }
//    
//    /// Moves each and every particle through a timer
//    func moveParticles() {
//        
//        let updateInterval: TimeInterval = 1.0 / 90.0
//        let particleSpeed: Float = 0.015
//        
//        moveParticleTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
//            
//            for particleEntity in particles {
//                particleEntity.position.z += particleSpeed
//                
//                if particleEntity.position.z > 23 {
//                    particleEntity.removeFromParent()
//                    
//                    
//                    if let index = particles.firstIndex(of: particleEntity) {
//                        particles.remove(at: index)
//                    }
//                }
//            }
//        }
//    }
//    
//    func stopParticles() {
//        particleTimer?.invalidate()
//        particleTimer = nil
//    }
}
