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

struct OrbitalParameters {
    let planet: String?
    let radius: Float
    let period: Float
    let position: Int
    var revolving: Bool = false
    
    init(planet: String?, radius: Float, period: Float, position: Int) {
        self.planet = planet
        self.radius = radius
        self.period = period
        self.position = position
    }
}

//define a random float value
let randomValue: Float = Float.random(in: 1...10)
//define the names of to load from the Package of Reality Composer
let planetDictionary: [String] = ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]

//define the reference so that we can simply adjust if needed
let time: Float = 20
//this is the value that is the minimum distance from the planet in the RealityComposer scene
let posValue: Float = 1.5
//and let's just shoot some numbers
var orbitalParameters: [OrbitalParameters] = [
    OrbitalParameters(planet: "Mercury", radius: posValue * 1, period: time * 1, position: 1),
    OrbitalParameters(planet: "Venus", radius: posValue * 2, period: time * 1.83, position: 2),
    OrbitalParameters(planet: "Earth", radius: posValue * 3, period: time * 2.25, position: 3),
    OrbitalParameters(planet: "Mars", radius: posValue * 4, period: time * 2.78, position: 4),
    OrbitalParameters(planet: "Jupiter", radius: posValue * 5, period: time * 3.65, position: 5),
    OrbitalParameters(planet: "Saturn", radius: posValue * 6, period: time * 4.3, position: 6),
    OrbitalParameters(planet: "Uranus", radius: posValue * 7, period: time * 5, position: 7),
    OrbitalParameters(planet: "Neptune", radius: posValue * 8, period: time * 5.9, position: 8)
]

func createSkyBox() -> Entity? {
    //mesh
    let largeSphere = MeshResource.generateSphere(radius: 1000)
    
    //material
    var skyBoxMaterial = UnlitMaterial()
    
    do {
        let texture = try TextureResource.load(named: "OpenSpace")
        skyBoxMaterial.color = .init(texture: .init(texture))
    } catch {
        print(error)
    }
    
    //skybox
    let skyBoxEntity = Entity()
    skyBoxEntity.components.set(
        ModelComponent(
            mesh: largeSphere,
            materials: [skyBoxMaterial]
        )
    )
    
    skyBoxEntity.scale *= .init(x: -1, y: 1, z: 1)
    
    return skyBoxEntity
}
