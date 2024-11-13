//
//  OrbitalParameters.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 26/10/24.
//

import Foundation

/// The parameters that interest the rotation and the revolution
/// - Parameter time: changes rotation (higher time = slower speed)
/// - Parameter posValue: changes distance from user (to update also in reality composer)
struct PlanetParameters {
    
    static let time: Float = 5
    static let posValue: Float = 3
    
    static var list = [
        PlanetCharacteristic(planet: "Mercury", radius: posValue * 1, period: time * 1),
        PlanetCharacteristic(planet: "Venus", radius: posValue * 2, period: time * 2),
        PlanetCharacteristic(planet: "Earth", radius: posValue * 3, period: time * 3),
        PlanetCharacteristic(planet: "Mars", radius: posValue * 4, period: time * 4),
        PlanetCharacteristic(planet: "Jupiter", radius: posValue * 5, period: time * 5),
        PlanetCharacteristic(planet: "Saturn", radius: posValue * 6, period: time * 6),
        PlanetCharacteristic(planet: "Uranus", radius: posValue * 7, period: time * 7),
        PlanetCharacteristic(planet: "Neptune", radius: posValue * 8, period: time * 8)
    ]
}

