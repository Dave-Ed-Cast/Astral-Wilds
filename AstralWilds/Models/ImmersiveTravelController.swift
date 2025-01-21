//
//  ImmersiveTravelController.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 11/01/25.
//

import SwiftUI
import RealityKit
import VisionTextArc

/// The controller for the immersive travel experience.
///
/// This class acts as a caller to all the other classes and functionalities involved.
/// See `ParticleController` or `TextController` for more information.
@MainActor
final class ImmersiveTravelController: ObservableObject {
    
    private var particleController: ParticleController
    private var textController: TextController
        
    private var textEntity = Entity()
    private var textCount = 100
    
    init() {
        self.particleController = .init()
        self.textController = .init()
    }
    
    
    /// Handles the creation of the particles for the immersive travel experience.
    ///
    /// Given the class is a `MainActor`, the task used will be on the said actor.
    /// - Parameters:
    ///   - environment: The lighting resource used
    ///   - onParticleCreated: When the particle is created, it can be used in the RealityView.
    func startParticles(
        environment: EnvironmentResource,
        onParticleCreated: @Sendable @escaping (AnchorEntity) -> Void
    ) {
        
        Task {
            while textController.currentStep <= textCount - 3 {
                print("start particles")
                try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                particleController.startParticles(environment: environment, onParticleCreated: onParticleCreated)
            }
        }
        
    }
    
    /// Calls the `startMovement` function in `ParticleController`.
    func moveParticles() {
        particleController.startMovement()
    }
    
    
    /// Creates the immersive 3D text leveraging the `VisionTextArc` package
    ///
    /// More information at `createText` funcion in the `Text` class
    /// - Parameters:
    ///   - textConfig: The configuration for the 3D text
    ///   - textArray: The array of text to make it 3D
    ///   - content: The reality view to add it in
    func createText(
        textConfig: TextCurver.Configuration,
        textArray: [String],
        content: @escaping (Entity) -> Void
    ) {
        
        textCount = textArray.count
        Task {
            try await Task.sleep(nanoseconds: 2_500_000_000) // 2.5 seconds
            while textController.currentStep <= textCount - 1 {
                print("start text")
                textEntity.removeFromParent()
                if let newText = await textController.createText(textConfig: textConfig, textArray: textArray) {
                    textEntity = newText
                }
                try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            }
        }
    }
}

/// The controller for the particles.
final class ParticleController {
    
    fileprivate var particles: [Entity] = []
    
    @MainActor
    fileprivate func startParticles(
        environment: EnvironmentResource,
        onParticleCreated: @escaping (AnchorEntity) -> Void
    ) {
        let newParticle = createParticle()
        newParticle.configureLighting(resource: environment, withShadow: true)
        particles.append(newParticle)
        onParticleCreated(newParticle)
    }
    
    @MainActor fileprivate func startMovement() {
        Task {
            try await Task.sleep(nanoseconds: 500_000_000)
            while !particles.isEmpty {
                for particle in particles {
                    updateParticlePosition(particle)
                }
                try await Task.sleep(nanoseconds: 11_111_111) // ~1/90 seconds
            }
        }
    }
    
    @MainActor private func updateParticlePosition(_ particle: Entity) {
        
        particle.position.z += 0.015
        if particle.position.z > 25 {
            particle.removeFromParent()
            if let index = particles.firstIndex(of: particle) {
                particles.remove(at: index)
            }
        }
    }
    
    @MainActor private func createParticle() -> AnchorEntity {
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

final class TextController {
    
    private var textCurver = TextCurver.self
    fileprivate var currentStep: Int = 0
    
    @MainActor fileprivate func createText(
        textConfig: TextCurver.Configuration,
        textArray: [String]
    ) async -> Entity? {
        
        let text = textArray[currentStep]
        let text3D = textCurver.curveText(text, configuration: textConfig)
        let environment = try? await EnvironmentResource(named: "studio")
        text3D.configureLighting(resource: environment!, withShadow: false)
        
        currentStep += 1
        
        return text3D
        
    }
}
