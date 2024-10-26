//
//  Parameters.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

// all the required libraries
import Foundation
import RealityKit
import RealityKitContent
import SwiftUI
import AVFoundation

/// This is a struct that contains all the
struct OrbitalParameters {
    let planet: String?
    let radius: Float
    let period: Float
    var revolving: Bool = false
    
    init(planet: String?, radius: Float, period: Float) {
        self.planet = planet
        self.radius = radius
        self.period = period
    }
}

//define the reference so that we can simply adjust if needed
let time: Float = 15
//a value that defines the distance from the planet in the RealityComposer scene
let posValue: Float = 1.5
//and let's just shoot some numbers
var orbitalParameters: [OrbitalParameters] = [
    OrbitalParameters(planet: "Mercury", radius: posValue * 1, period: time * 1.2),
    OrbitalParameters(planet: "Venus", radius: posValue * 2, period: time * 1.8),
    OrbitalParameters(planet: "Earth", radius: posValue * 3, period: time * 3.4),
    OrbitalParameters(planet: "Mars", radius: posValue * 4, period: time * 4.34),
    OrbitalParameters(planet: "Jupiter", radius: posValue * 5, period: time * 6.21),
    OrbitalParameters(planet: "Saturn", radius: posValue * 6, period: time * 7.8),
    OrbitalParameters(planet: "Uranus", radius: posValue * 7, period: time * 9.3),
    OrbitalParameters(planet: "Neptune", radius: posValue * 8, period: time * 11.1)
]

/// This is a function that creates a skybox in which it encapsulates the player
/// - Returns: the skybox entity
func createSkyBox() -> Entity? {
    //create the mesh
    let largeSphere = MeshResource.generateSphere(radius: 600)
    
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

let mesh = MeshResource.generateSphere(radius: 0.02)

let normalizationValue = 255.0
let color = UIColor(
    red: 205 / normalizationValue,
    green: 209 / normalizationValue,
    blue: 228 / normalizationValue,
    alpha: 0.05)

func createParticle() -> AnchorEntity {
    
    let material = SimpleMaterial(color: color, isMetallic: false)
        
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

