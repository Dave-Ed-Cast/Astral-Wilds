//
//  ParticleController.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 26/02/25.
//

import SwiftUI
import RealityKit

/// The particle controller handles the creation of particles and their movement
final class ParticleController {
    
    /// The array of entities to move each
    private var particles: [Entity]
    
    init() {
        self.particles = []
    }
    
    /// Handles the start process to control particles.
    ///
    /// First, uses `create` to return a particle, then populates the `particles` entity array to move them
    /// - Returns: returns a created particle to be used
    @MainActor func start() async -> AnchorEntity {
        let environment = try? await EnvironmentResource(named: "studio")
        let newParticle = create()
        newParticle.configureLighting(resource: environment!, withShadow: false)
        particles.append(newParticle)
        return newParticle
    }
    
    /// Handles the movement of each individual particle in the `particles` array
    @MainActor func startMovement() {
        Task {
            // This prevents the particles array to be found empty
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            while !particles.isEmpty {
                for particle in particles {
                    updatePosition(particle)
                }
                try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 / 240)) // 1/240 seconds
            }
        }
    }
    
    /// Helper function for the movement. Updates the position
    /// - Parameter particle: The singular particle to move
    @MainActor private func updatePosition(_ particle: Entity) {
        
        particle.position.z += 0.0075
        if particle.position.z > 26 {
            particle.removeFromParent()
            if let index = particles.firstIndex(of: particle) {
                particles.remove(at: index)
            }
        }
    }
    
    /// Helper function for the creation. Creates a particle
    /// - Returns: The particle created with its configuration
    @MainActor private func create() -> AnchorEntity {
        let material = SimpleMaterial(color: UIColor(Color("particleColor").opacity(0.15)), isMetallic: false)
        let mesh = MeshResource.generateSphere(radius: 0.02)
        let particleEntity = ModelEntity(mesh: mesh, materials: [material])
        
        var randomX: Float
        var randomY: Float
        
        repeat {
            randomX = Float.random(in: -4...4)
        } while randomX >= -0.3 && randomX <= 0.3
        
        repeat {
            randomY = Float.random(in: -2...2)
        } while randomY >= 0.7 && randomY <= 1
        
        let anchor = AnchorEntity(world: [randomX, randomY, -25.0])
        anchor.addChild(particleEntity)
        return anchor
    }
}
