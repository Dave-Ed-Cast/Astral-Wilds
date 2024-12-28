//
//  Parameters.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

/// This is contains all the characteristic of a planet
/// - Parameter planet: Name of the planet
/// - Parameter radius: To determine the rotation
/// - Parameter period: Period of revolution
/// - Parameter revolving: If it is revolving or not
struct PlanetCharacteristic {
    let planet: String
    let radius: Float
    let period: Float
    var revolving: Bool = false

    init(planet: String, radius: Float, period: Float) {
        self.planet = planet
        self.radius = radius
        self.period = period
    }
}
 
