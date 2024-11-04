//
//  Planets.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

/// Like in the other immersive spaces, we need to first create the skybox.
/// Then, we need to load the associated scene with the lights.
struct MovePlanets: View {
    
    @Environment(\.setMode) var setMode
    
    @State private var angles: [Float] = (0..<8).map { _ in
        Float.pi * Float.random(in: 1...10)
    }
    
    private let planetDictionary: [String] = [
        "Mercury",
        "Venus",
        "Earth",
        "Mars",
        "Jupiter",
        "Saturn",
        "Uranus",
        "Neptune"
    ]
    private let orbitalParameters = PlanetParameters.list
    
    var body: some View {
        
        RealityView { content in

            guard let skyBoxEntity = content.createSkyBox() else {
                return
            }
            content.add(skyBoxEntity)
            
            //This is safe to unwrap, it's for readability to write like this
            if let scene = try? await Entity(named: "Planets", in: realityKitContentBundle), let environment = try? await EnvironmentResource(named: "studio") {
                
                scene.components.set(ImageBasedLightComponent(source: .single(environment)))
                scene.components.set(ImageBasedLightReceiverComponent(imageBasedLight: scene))
                scene.components.set(GroundingShadowComponent(castsShadow: true))
                content.add(scene)
                
                movePlanetsInLoop(inside: scene)
            }
        }
    }
    
    /// Will make the entity revolve and rotate according to math formulas.
    /// Rotation has to happen continuosly, so a timer is needed.
    /// It has to be smooth, therefore we are repeat everything each millisecond.
    ///
    /// For each angle and index define the parameters, then find the planet associated and modify it.
    /// Most of the formula is trial and error
    /// - Parameter entity: the entity that will be rotated and will revolve around the sun
    private func movePlanetsInLoop(inside entity: Entity) {
        
        let updateInterval: Double = 1.0 / 90.0
        let angularSpace = 2 * Float.pi
        let rotationAngle: Float = 0.005

        Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            
            for (index, angle) in angles.enumerated() {
                
                let parameters = orbitalParameters[index]
                let x = parameters.radius * cos(angle)
                let z = parameters.radius * sin(angle)
                let newPosition = SIMD3(x, 0, z)
                
                //dictionary created from developer, safe to unwrap
                let planet = planetName(for: entity, in: planetDictionary[index])!
                
                let rotateClockwise = (planet.name == "Venus" || planet.name == "Uranus")
                let rotationDirection: Float = rotateClockwise ? 1.0 : -1.0
                
                planet.position = newPosition
                
                planet.transform.rotation *= simd_quatf(
                    angle: rotationDirection * rotationAngle,
                    axis: [0, 0.8, 0]
                )
                
                //angular velocity is 2pi / period
                let angularVelocity = angularSpace / parameters.period
                angles[index] -= 0.001 * Float(angularVelocity)
            }
        }
    }
    
    /// Finds the planet name through Depth First Search method
    ///
    /// - Parameters:
    ///   - entity: the particular entity
    ///   - name: associated name in the dictionary
    /// - Returns: return that entity with the associated name in the dictionary
    private func planetName(for entity: Entity, in name: String) -> Entity? {
        var tempEntityArray = [entity]
        
        while !tempEntityArray.isEmpty {
            let current = tempEntityArray.removeLast()
            if current.name == name {
                return current
            }
            
            tempEntityArray.append(contentsOf: current.children)
        }
        
        return nil
    }
    
}
