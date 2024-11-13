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
    
    /// This is a function that creates a skybox in which it encapsulates the user
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
        let mesh = MeshResource.generateSphere(radius: 0.01)
        
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
}

//    /// This is a function that creates a skybox in which it encapsulates the player
//    /// - Returns: the skybox entity
//    func createSkyBox() -> Entity {
//        // Generate a large plane to act as the "window"
//        let radius: Float = 30.0  // Large radius to make the curve subtle
//        let width: Float = 0.0   // Height of the window area
//        let windowCylinder = MeshResource.generatePlane(width: 7.5, depth: 5.0, cornerRadius: 5.0)
//
//        var windowMaterial = UnlitMaterial()
//
//        // Load a texture with transparency or a centered effect for the window
//        do {
//            let texture = try TextureResource.load(named: "OpenSpace")  // Use a texture with transparency at edges
//            windowMaterial.color = .init(texture: .init(texture))
//        } catch {
//            print("Failed to load texture: \(error)")
//        }
//
//        // Create the window entity
//        let windowEntity = Entity()
//        windowEntity.components.set(
//            ModelComponent(
//                mesh: windowCylinder,
//                materials: [windowMaterial]
//            )
//        )
//
//        let currentAngle: Float = -90.0
//
//        let x = radius * cos(currentAngle)
//        let z = radius * sin(currentAngle)
//
//        let lookAtUser = SIMD3(-x, 0, -z)
//
//        // Rotate the cylinder by 90 degrees on the Y-axis to face the player
//        windowEntity.transform.rotation = simd_quatf(angle: .pi / 2, axis: [1, 0, 0])
//
//        // Position the cylinder in front of the player and invert if needed
//        windowEntity.position = [0, 0.5, -1.5]
//        windowEntity.scale *= .init(x: -1, y: 1, z: 1)  // Invert along the X-axis to view from inside the cylinder
//
//        return windowEntity
//
//    }
