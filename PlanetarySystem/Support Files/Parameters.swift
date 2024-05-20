//
//  Parameters.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

import Foundation
import RealityKit
import RealityKitContent
import SwiftUI
import AVFoundation
import SceneKit

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

//define the names of to load from the Package of Reality Composer
let planetDictionary: [String] = ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]

//define the reference so that we can simply adjust if needed
let time: Float = 20
//this is the value that is the minimum distance from the planet in the RealityComposer scene
let posValue: Float = 1.5
//and let's just shoot some numbers
var orbitalParameters: [OrbitalParameters] = [
    OrbitalParameters(planet: "Mercury", radius: posValue * 1, period: time * 0.9),
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
    let largeSphere = MeshResource.generateSphere(radius: 1000)
    
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
    let mesh = MeshResource.generateSphere(radius: 0.02)
//    let material = SimpleMaterial(color: .white, isMetallic: false)
    
    let normalizationValue = 255.0
    let color = UIColor(
        red: 205 / normalizationValue,
        green: 209 / normalizationValue,
        blue: 228 / normalizationValue,
        alpha: 1.0)
    
    let material = SimpleMaterial(color: color, isMetallic: false)
        
    let particleEntity = ModelEntity(
        mesh: mesh,
        materials: [material]
    )
    let randomX = Float.random(in: -2...2)
    let randomY = Float.random(in: -0.5...1.8)
    let randomZ = Float.random(in: -50 ... -10)
    let anchor = AnchorEntity(world: [randomX, randomY, randomZ]) // Set the initial position of the particle
    anchor.addChild(particleEntity)
    return anchor
}
