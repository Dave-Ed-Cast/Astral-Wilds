//
//  RealityViewExtension.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 27/10/24.
//

import Foundation
import SwiftUI
import RealityKit

extension RealityViewContent {
    
    /// This is a function that creates a skybox in which it encapsulates the player
    /// - Returns: the skybox entity
    func createSkyBox() -> Entity {
        
        let largeSphere = MeshResource.generateSphere(radius: 35)
        var skyBoxMaterial = UnlitMaterial()
        
        do {
            let texture = try TextureResource.load(named: "OpenSpace")
            skyBoxMaterial.color = .init(texture: .init(texture))
        } catch {
            print(error)
        }
        
        let skyBoxEntity = Entity()
        skyBoxEntity.components.set(
            ModelComponent(
                mesh: largeSphere,
                materials: [skyBoxMaterial]
            )
        )
        
        // x = -1 because it has to be seen from the inside
        skyBoxEntity.scale *= .init(x: -1, y: 1, z: 1)
        return skyBoxEntity
    }
    
    /// This creates particles for the immersive travel. They are thrown at the player to simulate the voyage
    /// - Returns: the anchor entity point of where the range of particles should spawn
    func createParticle() -> AnchorEntity {
        
        let material = SimpleMaterial(color: UIColor(Color("particleColor").opacity(0.1)), isMetallic: false)
        let mesh = MeshResource.generateSphere(radius: 0.02)
        
        let particleEntity = ModelEntity(
            mesh: mesh,
            materials: [material]
        )
        
        var randomX: Float
        var randomY: Float
        
        repeat {
            randomX = Float.random(in: -4...4)
        } while randomX >= -0.3 && randomX <= 0.3
        
        repeat {
            randomY = Float.random(in: -2...2)
        } while randomY >= 0.7 && randomY <= 1
        
        let anchor = AnchorEntity(world: [randomX, randomY, -20.0])
        anchor.addChild(particleEntity)
        
        return anchor
    }
    
    @MainActor func setUpLightForEntity(
        resourceName name: String,
        for entity: Entity,
        withShadow shadow: Bool
    ) async {
        do {
            let environment = try await EnvironmentResource(named: name)
            entity.components.set(ImageBasedLightComponent(source: .single(environment)))
            entity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: entity))
            entity.components.set(GroundingShadowComponent(castsShadow: shadow))
        } catch {
            print("Failed to load environment resource: \(error)")
        }
    }
}
