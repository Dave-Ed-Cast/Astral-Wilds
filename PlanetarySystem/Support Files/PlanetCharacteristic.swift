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
 
