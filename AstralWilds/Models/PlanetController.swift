//
//  OrbitalParameters.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 26/10/24.
//

import SwiftUI
import RealityFoundation

/// Contains all the parameters and functions related to planets chracteristic and their movement.
final class PlanetController {
    
    @MainActor static let shared = PlanetController()
    
    /// The parameters that define the planet
    ///
    /// - Parameters:
    ///   - planet: Name of the planet
    ///   - radius: To determine the rotation
    ///   - period: Period of revolution
    ///   - revolving: If it is revolving or not
    private struct Descriptor {
        
        let planet: String
        let radius: Float
        let period: Float
        
        var revolving: Bool
        
        init(planet: String, radius: Float, period: Float) {
            self.planet = planet
            self.radius = radius
            self.period = period
            self.revolving = false
        }
    }
    
    private let time: Float
    private let posValue: Float
    
    private var timers: [String: Timer] = [:]
    private var list: [Descriptor]
    
    /// Initialize with custom time and posValue
    private init(time: Float = 10, posValue: Float = 3) {
        self.time = time
        self.posValue = posValue
        
        self.list = [
            Descriptor(planet: "Mercury", radius: posValue * 1, period: time * 1),
            Descriptor(planet: "Venus", radius: posValue * 2, period: time * 2),
            Descriptor(planet: "Earth", radius: posValue * 3, period: time * 3),
            Descriptor(planet: "Mars", radius: posValue * 4, period: time * 4),
            Descriptor(planet: "Jupiter", radius: posValue * 5, period: time * 5),
            Descriptor(planet: "Saturn", radius: posValue * 6, period: time * 6),
            Descriptor(planet: "Uranus", radius: posValue * 7, period: time * 7),
            Descriptor(planet: "Neptune", radius: posValue * 8, period: time * 8)
        ]
    }
    
    /// Fetch the planet parameters by entity name
    private func getPlanetParameters(for entityName: String) -> Descriptor? {
        return list.first { $0.planet == entityName }
    }
    
    @MainActor private func move(_ entity: Entity, with parameters: Descriptor) {

        if let index = list.firstIndex(where: { $0.planet == entity.name }) {
            list[index].revolving = true
        }
        
        let initialAngle = atan2(entity.position.z, entity.position.x)
        let rotationAngle: Float = 0.0025
        let spinRotation: Float = rotationAngle * 3
        
        let updateInterval: Double = 1.0 / 90.0
        let angularSpace = 2.0 * Float.pi
        let angularVelocity = angularSpace / parameters.period
        
        let radius = parameters.radius
        let isRetrograde = (entity.name == "Venus" || entity.name == "Uranus")
        let rotation = isRetrograde ? -spinRotation : spinRotation
        let rotationAxis = isRetrograde ? SIMD3(0, -entity.position.y, 0) : SIMD3(0, entity.position.y, 0)
        
        var angle = initialAngle
        let timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            Task { @MainActor in
                angle -= rotationAngle * Float(angularVelocity)
                let x = radius * cos(angle)
                let z = radius * sin(angle)
                let newPosition = SIMD3(x, entity.position.y, z)
                entity.position = newPosition
                entity.transform.rotation *= simd_quatf(angle: rotation, axis: rotationAxis)
            }
        }
        
        timers[entity.name] = timer
    }
    
    @MainActor private func stop(_ entity: Entity) {

        guard let timer = timers[entity.name] else { return }
        timer.invalidate()
        timers[entity.name] = nil
        
        if let index = list.firstIndex(where: { $0.planet == entity.name }) {
            list[index].revolving = false
        }
    }
    
    @MainActor func movePlanet(_ entity: Entity) {
        guard let parameters = getPlanetParameters(for: entity.name) else {
            return
        }
        
        parameters.revolving ? stop(entity) : move(entity, with: parameters)
    }
}
