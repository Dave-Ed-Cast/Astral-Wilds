//
//  ImmersiveTravelController.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 11/01/25.
//

import SwiftUI
import RealityKit
import VisionTextArc

@MainActor
class ImmersiveTravelController: ObservableObject {
    
    private var particleController: ParticleController
    private var textController: TextController
    private var timerManager: TimerManager
    
    private var textEntity = Entity()
    
    init() {
        self.particleController = .init()
        self.textController = .init()
        self.timerManager = .shared
    }
    
    func startParticles(environment: EnvironmentResource, onParticleCreated: @escaping (AnchorEntity) -> Void) {
        timerManager.asyncTimer(id: "particles", timeInterval: 0.2) { [self] in
            guard textController.currentStep <= 1 else { return }
            particleController.startParticles(environment: environment, onParticleCreated: onParticleCreated)
        }
    }
    
    func moveParticles() {
        particleController.startMovement()
    }
    
    func createText(textConfig: TextCurver.Configuration, textArray: [String], content: RealityViewContent) async {
        
        timerManager.asyncTimer(id: "text", timeInterval: 5.0) { [self] in
            textEntity.removeFromParent()
            let newText = await textController.createText(textConfig: textConfig, textArray: textArray)!
            withAnimation { textEntity = newText }
            content.add(newText)
        }
    }
}

@MainActor
final class ParticleController {
    
    private var particles: [Entity]
    private var timerManager: TimerManager
    
    fileprivate init() {
        self.particles = []
        self.timerManager = .shared
    }
    
    func startParticles(environment: EnvironmentResource, onParticleCreated: @escaping (AnchorEntity) -> Void) {
        let newParticle = createParticle()
        newParticle.configureLighting(resource: environment, withShadow: true)
        particles.append(newParticle)
        onParticleCreated(newParticle)
        
    }
    
    func startMovement() {
        timerManager.asyncTimer(id: "particle movement", timeInterval: 1.0 / 90.0) { [self] in
            for particle in particles {
                particle.position.z += 0.015
                if particle.position.z > 25 {
                    particle.removeFromParent()
                    if let index = particles.firstIndex(of: particle) {
                        particles.remove(at: index)
                    }
                }
            }
        }
    }
    
    private func createParticle() -> AnchorEntity {
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
    private var timerManager: TimerManager
    
    var currentStep: Int
        
    @MainActor fileprivate init() {
        self.timerManager = .shared
        self.currentStep = 0
    }
    
    func createText(textConfig: TextCurver.Configuration, textArray: [String]) async -> Entity? {
        
        let text = textArray[currentStep]
        let text3D = await textCurver.curveText(text, configuration: textConfig)
        let environment = try? await EnvironmentResource(named: "studio")
        await text3D.configureLighting(resource: environment!, withShadow: false)
        
        await updateStep(textArray: textArray)
        
        return text3D
        
    }
    
    @MainActor func updateStep(textArray: [String]) {
        
        guard currentStep < textArray.count else {
            timerManager.invalidateTimer(id: "particle movement")
            return
        }
        currentStep += 1
        
        let lastStep = (currentStep == textArray.count - 1)
        let fourthToLast = (currentStep == textArray.count - 4)
        
        if lastStep {
            timerManager.invalidateTimer(id: "move particles")
            timerManager.invalidateTimer(id: "text")
            print("stopping the movement of particles and the text")
        }
        
        if fourthToLast {
            timerManager.invalidateTimer(id: "particles")
            print("Stopping the creation of particles")
        }
    }
}
