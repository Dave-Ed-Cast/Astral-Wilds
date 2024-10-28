//
//  OrbitalParameters.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 26/10/24.
//

import Foundation

struct PlanetParameters {
    
    static let time: Float = 25
    static let posValue: Float = 1.5
    
    static var list = [
        PlanetCharacteristic(planet: "Mercury", radius: posValue * 1, period: time * 1.2),
        PlanetCharacteristic(planet: "Venus", radius: posValue * 2, period: time * 1.8),
        PlanetCharacteristic(planet: "Earth", radius: posValue * 3, period: time * 3.4),
        PlanetCharacteristic(planet: "Mars", radius: posValue * 4, period: time * 4.34),
        PlanetCharacteristic(planet: "Jupiter", radius: posValue * 5, period: time * 6.21),
        PlanetCharacteristic(planet: "Saturn", radius: posValue * 6, period: time * 7.8),
        PlanetCharacteristic(planet: "Uranus", radius: posValue * 7, period: time * 9.3),
        PlanetCharacteristic(planet: "Neptune", radius: posValue * 8, period: time * 11.1)
    ]
}

