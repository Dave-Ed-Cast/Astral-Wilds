//
//  Parameters.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

import Foundation

struct OrbitalParameters {
    let radius: Float //orbit radius
    let period: Float //orbit period (time for one revolution)
}

//define a random float value
let randomValue: Float = Float.random(in: 1...10)
//define the names of to load from the Package of Reality Composer
let planetDictionary: [String] = ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]

//define the reference so that we can simply adjust if needed
let velocityFactor: Float = 20

//and let's just shoot some numbers
let orbitalParameters: [OrbitalParameters] = [
    //mercury
    OrbitalParameters(radius: 1, period: velocityFactor * 1),
    //venus
    OrbitalParameters(radius: 2, period: velocityFactor * 1.83),
    //earth
    OrbitalParameters(radius: 3, period: velocityFactor * 2.25),
    //mars
    OrbitalParameters(radius: 4, period: velocityFactor * 2.78),
    //jupiter
    OrbitalParameters(radius: 5, period: velocityFactor * 3.65),
    //saturn
    OrbitalParameters(radius: 6, period: velocityFactor * 4.3),
    //uranus
    OrbitalParameters(radius: 7, period: velocityFactor * 5),
    //neptune
    OrbitalParameters(radius: 8, period: velocityFactor * 5.9)
]
