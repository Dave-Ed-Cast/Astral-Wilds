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
@Observable
final class ImmersiveTravelController {
    
    /// The duration of the travel, therefore, the text length chosen by the user.
    /// It is imperative to assign to this variable the text array.
    var textArray: [String] = [] {
        didSet {
            maxStepCounter = textArray.count
        }
    }
    
    /// The duration variable holds the information from the user to allow the
    /// particle emitter to be properly adjusted.
    var duration: Int = 0 {
        didSet {
            selectedDuration = (duration == 0 ? 38 : 120)
        }
    }
    
    /// Holds the scene in which to find the particles
    var sceneHolder: Entity?
    
    /// Detects when the travel experience will must end
    private var ended: Bool = false
    
    private var textEntity: Entity
    
    /// Everything depends on the step of the travel
    private var maxStepCounter: Int = 0
    private var selectedDuration: Int = 0
    
    private let textController: TextController
    
    @MainActor init() {
        self.textController = .init()
        self.textEntity = .init()
    }
    
    /// Handles the update of 3D text during the immersive travel
    ///
    /// This function executes a Task in which handles the removal and addition of the text.
    /// Leveraging the package `VisionTextArc`, it is possible to create curved text.
    /// - Parameters:
    ///   - textArray: The array of text to make it 3D
    ///   - config: The configuration for the 3D text, provided by `VisionTextArc.Configuration`
    ///   - view: The reality view to add it in
    @MainActor func createText(
        _ textArray: [String],
        config: TextCurver.Configuration,
        view: RealityViewContent
    ) {
        Task {
            try await Task.sleep(for: .seconds(2.5))
            while !ended {
                textEntity = await textController.create(config: config, textArray: textArray)
                view.add(textEntity)
                
                try await Task.sleep(for: .seconds(5))
                if textController.currentStep == maxStepCounter {
                    ended = true
                    break
                }
                textEntity.removeFromParent()
            }
        }
    }
    
    /// Activates and lighlty modifies the particle emitter in the scene.
    ///
    /// The function updates the settings of the existing particle emitter
    /// and triggers the emission for a duration specified by `selectedDuration`.
    ///
    /// The emitter is configured through reality composer pro.
    /// - Note: The emission duration is dynamically set to `selectedDuration`.
    @MainActor func particleEmitter() {
        Task {
            guard let particleHolder = sceneHolder?.findEntity(named: "ParticlesHolder"),
                  let particles = particleHolder.findEntity(named: "Particles"),
                  let particleEntity = particles.children.first
            else { return }
            print("got it")
            particleEntity.isEnabled = false
                
            guard var emitter = particleEntity.components[ParticleEmitterComponent.self] else { return }

            print(selectedDuration)
            emitter.timing = .once(warmUp: 0.2, emit: .init(duration: TimeInterval(selectedDuration)))
            emitter.isEmitting = true
            particleEntity.components.set(emitter)

            try? await Task.sleep(for: .seconds(7.5))
            particleEntity.isEnabled = true
        }
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
