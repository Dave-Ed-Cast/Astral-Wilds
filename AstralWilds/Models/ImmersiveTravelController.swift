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
    
    /// The duration of the travel, therefore, the text length chosen by the user.
    /// It is imperative to assign to this variable the text array.
    @Published var textArray: [String] = [] {
        didSet {
            maxStepCounter = textArray.count
        }
    }
    
    @Published var ended: Bool = false
    
    private var textEntity: Entity
    
    private var particleController: ParticleController
    private var textController: TextController
    
    /// Everything depends on the step of the travel
    private var maxStepCounter: Int = 0
    
    /// Initializes the classes `ParticleController` and `TextController`
    init() {
        self.particleController = .init()
        self.textController = .init()
        self.textEntity = .init()
    }
    
    /// Starts the creation of the particles for the immersive travel experience.
    ///
    /// This function executes a task that creates a particle every 0.2 seconds,
    /// then, adds it to the reality view.
    /// - Parameter view: The Reality View to add the anchor
    func startParticles(view: RealityViewContent) {
        
        Task {
            while textController.currentStep <= maxStepCounter - 3 {
                try await Task.sleep(nanoseconds: 200_000_000) // 0.2 seconds
                let particle = await particleController.start()
                view.add(particle)
            }
        }
    }
    
    /// Moves each and every particle created to simulate the travel
    ///
    /// Calls the `startMovement` function in `ParticleController`.
    func moveParticles() {
        particleController.startMovement()
    }
    
    /// Handles the update of 3D text during the immersive travel
    ///
    /// This function executes a Task in which handles the removal and addition of the text.
    /// Leveraging the package `VisionTextArc`, it is possible to create curved text.
    /// It is later added in the reality view.
    /// - Parameters:
    ///   - textArray: The array of text to make it 3D
    ///   - config: The configuration for the 3D text, provided by `VisionTextArc.Configuration`
    ///   - view: The reality view to add it in
    func createText(
        _ textArray: [String],
        config: TextCurver.Configuration,
        view: RealityViewContent
    ) {
        
        Task {
            try await Task.sleep(nanoseconds: 2_500_000_000) // 2.5 seconds
            while !ended {
                
                textEntity = await textController.create(config: config, textArray: textArray)
                view.add(textEntity)
                
                try await Task.sleep(nanoseconds: 5_000_000_000) // 5 second
                if textController.currentStep == maxStepCounter {
                    ended = true
                    break
                }
                withAnimation {
                    textEntity.removeFromParent()
                }
            }
        }
    }
}

/// The particle controller handles the creation of particles and their movement
final class ParticleController {
    
    /// The array of entities to move each
    fileprivate var particles: [Entity]
    
    fileprivate init() {
        self.particles = []
    }
    
    /// Handles the start process to control particles.
    ///
    /// First, uses `create` to return a particle, then populates the `particles` entity array to move them
    /// - Returns: returns a created particle to be used
    @MainActor fileprivate func start() async -> AnchorEntity {
        let environment = try? await EnvironmentResource(named: "studio")
        let newParticle = create()
        newParticle.configureLighting(resource: environment!, withShadow: false)
        particles.append(newParticle)
        return newParticle
    }
    
    /// Handles the movement of each individual particle in the `particles` array
    @MainActor fileprivate func startMovement() {
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

/// The text controller class leverages the `VisionTextArc` package.
///
/// It allows for curved 3D text to be displayed to the user through a private function: `create`
final class TextController {
    
    private var textCurver = TextCurver.self
    
    /// The current step is one of the most important variables.
    /// It allows to understand at which part of the journey we are.
    fileprivate var currentStep: Int = 0
    
    /// Creates a 3D text leveraging the `VisionTextArc` package
    ///
    /// - Parameters:
    ///   - config: The configuration needed
    ///   - textArray: The entire array (this way list of strings in 3D can be created)
    /// - Returns: A 3D text entity
    @MainActor fileprivate func create(
        config: TextCurver.Configuration,
        textArray: [String]
    ) async -> Entity {
        
        let text = textArray[currentStep]
        let text3D = textCurver.curveText(text, configuration: config)
        let environment = try? await EnvironmentResource(named: "studio")
        text3D.configureLighting(resource: environment!, withShadow: false)
        
        currentStep += 1
        
        return text3D
    }
}
