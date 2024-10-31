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
    func createSkyBox() -> Entity? {
        //create the mesh
        let largeSphere = MeshResource.generateSphere(radius: 35)
        
        //material for the skybox
        var skyBoxMaterial = UnlitMaterial()
        
        //lodaing the image can throw errors due to lack of the asset
        do {
            let texture = try TextureResource.load(named: "OpenSpace")
            skyBoxMaterial.color = .init(texture: .init(texture))
        } catch {
            print(error)
        }
        
        //define the skybox
        let skyBoxEntity = Entity()
        skyBoxEntity.components.set(
            ModelComponent(
                mesh: largeSphere,
                materials: [skyBoxMaterial]
            )
        )
        
        //scale the skybox for mesh reasons
        skyBoxEntity.scale *= .init(x: -1, y: 1, z: 1)
        return skyBoxEntity
    }
    
    func createParticle() -> AnchorEntity {
        
        let material = SimpleMaterial(color: UIColor(Color("particleColor").opacity(0.05)), isMetallic: false)
        let mesh = MeshResource.generateSphere(radius: 0.02)
        
        let particleEntity = ModelEntity(
            mesh: mesh,
            materials: [material]
        )
        
        let randomX = Float.random(in: -4...4)
        let randomY = Bool.random() ? Float.random(in: -2 ... -0.5) : Float.random(in: 0.5...2)
        
        let anchor = AnchorEntity(world: [randomX, randomY, -20.0])
        anchor.addChild(particleEntity)
        return anchor
    }
}
