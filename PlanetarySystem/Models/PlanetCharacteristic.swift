//
//  Parameters.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

import Foundation

/// This is contains all the characteristic of a planet
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
 
