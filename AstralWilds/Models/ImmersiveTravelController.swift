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
                try await Task.sleep(for: .seconds(0.2))
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
            try await Task.sleep(for: .seconds(2.5))
            while !ended {
                
                textEntity = await textController.create(config: config, textArray: textArray)
                view.add(textEntity)
                
                try await Task.sleep(for: .seconds(5))
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
