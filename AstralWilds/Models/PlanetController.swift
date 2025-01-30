//
//  OrbitalParameters.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 26/10/24.
//

import SwiftUI
import RealityFoundation

/// Contains all the parameters and functions related to planets chracteristic and their movement.
///
/// The class is strictly used in the second use case of the app, that features a playground for the user to interact freely with each planet.
/// To note that only certain items are `MainActor` because it is not needed for the entire class to be so.
final class PlanetController {
    
    /// Holds a shared value for the interaction with the selected planet
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
    
    //arbitrary values that help define the radius and period to conform with RealityComposerPro's scene.
    private let time: Float
    private let posValue: Float
    
    private var taskHolder: [String: Task<Void, Never>] = [:]
    private var list: [Descriptor]
    
    /// Initialize with custom time and posValue. Defaults are provided
    private init(time: Float = 8, posValue: Float = 3) {
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
    
    /// Tries to reposition the entity in a suitable position when the user wants to rotate it
    /// - Parameters:
    ///   - entity: The entity to reposition
    ///   - parameters: The parameters to follow
    private func resetEntity(_ entity: Entity, with parameters: Descriptor) {
        
        Task { @MainActor in
            if entity.position != SIMD3(0, 0.9, parameters.radius) {
                entity.position = SIMD3(0, 0.9, parameters.radius)
            }
        }
    }
    
    /// The move function allows for the control of the movement of planet, regarding its parameters.
    ///
    /// The math here revolves on basic calculus:
    ///  - First: we calculate the parameters needed (angle, rotation and spin)
    ///  - Second: we define the angular velocity
    ///  - Third: understand if the planet should rotate counter-clockwise or not
    ///  - Fourth: finally, update the movement.
    ///
    ///  Each planet that started movement, will be assigned to the `taskHolder` so that can be later stopped
    ///
    /// - Parameters:
    ///   - entity: The planet to move
    ///   - parameters: The parameters of the planet
    @MainActor private func move(_ entity: Entity, with parameters: Descriptor) {
        if let index = list.firstIndex(where: { $0.planet == entity.name }) {
            resetEntity(entity, with: parameters)
            list[index].revolving = true
        }
        
        let initialAngle = atan2(entity.position.z, entity.position.x)
        let rotationAngle: Float = 0.002
        let spinRotation: Float = rotationAngle * 2
        
        let angularSpace = 2.0 * Float.pi
        let angularVelocity = angularSpace / parameters.period
        
        let radius = parameters.radius
        let isRetrograde = (entity.name == "Venus" || entity.name == "Uranus")
        let rotation = isRetrograde ? -spinRotation : spinRotation
        let rotationAxis = isRetrograde ? SIMD3(0, -entity.position.y, 0) : SIMD3(0, entity.position.y, 0)
        
        var angle = initialAngle
        
        let task = Task {
            while self.list.first(where: { $0.planet == entity.name })?.revolving == true {
                let x = radius * cos(angle)
                let z = radius * sin(angle)
                let newPosition = SIMD3(x, entity.position.y, z)
                angle -= rotationAngle * Float(angularVelocity)
                
                entity.position = newPosition
                entity.transform.rotation *= simd_quatf(angle: rotation, axis: rotationAxis)
                
                try? await Task.sleep(nanoseconds: UInt64(1_000_000_000 / 90)) // 1/90 seconds
            }
        }
        
        taskHolder[entity.name] = task
    }
    
    /// Stops the entity that is moving, after finding it from `taskHolder`
    /// - Parameter entity: the entity that must be stopped
    @MainActor private func stop(_ entity: Entity) {
        guard let task = taskHolder[entity.name] else { return }
        task.cancel()
        taskHolder[entity.name] = nil
        
        if let index = list.firstIndex(where: { $0.planet == entity.name }) {
            list[index].revolving = false
        }
    }
    
    /// Allows to move the planet which the user interacts with
    /// - Parameter entity: The planet to move
    @MainActor func moveThisPlanet(_ entity: Entity) {
        guard let parameters = getPlanetParameters(for: entity.name) else {
            return
        }
        
        parameters.revolving ? stop(entity) : move(entity, with: parameters)
    }
}
