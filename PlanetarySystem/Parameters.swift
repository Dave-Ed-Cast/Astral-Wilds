//
//  Parameters.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

import Foundation

struct OrbitalParameters {
    let planet: String? //planet
    let radius: Float //orbit radius
    let period: Float //orbit period (time for one revolution)
    let position: Int
    var revolving: Bool = false
    
    init(planet: String? = nil, radius: Float, period: Float, position: Int) {
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
let velocityFactor: Float = 20

//and let's just shoot some numbers
let orbitalParameters: [OrbitalParameters] = [
    OrbitalParameters(planet: "Mercury", radius: 1, period: velocityFactor * 1, position: 1),
    OrbitalParameters(planet: "Venus", radius: 2, period: velocityFactor * 1.83, position: 2),
    OrbitalParameters(planet: "Earth", radius: 3, period: velocityFactor * 2.25, position: 3),
    OrbitalParameters(planet: "Mars", radius: 4, period: velocityFactor * 2.78, position: 4),
    OrbitalParameters(planet: "Jupiter", radius: 5, period: velocityFactor * 3.65, position: 5),
    OrbitalParameters(planet: "Saturn", radius: 6, period: velocityFactor * 4.3, position: 6),
    OrbitalParameters(planet: "Uranus", radius: 7, period: velocityFactor * 5, position: 7),
    OrbitalParameters(planet: "Neptune", radius: 8, period: velocityFactor * 5.9, position: 8)
]

