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
    
    @Environment(\.setMode) private var setMode
    
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

            let skyBoxEntity = content.createSkyBox()
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
    /// Rotates and revolves the entity using a timer.
    /// Parameters are set within the function for the corresponding planet.
    /// - Parameter entity: the entity that will be rotated and will revolve around the sun
    private func movePlanetsInLoop(inside entity: Entity) {
        
        let updateInterval: Double = 1.0 / 90.0
        let angularSpace = 2.0 * Float.pi
        let rotationAngle: Float = 0.003

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
                    axis: [0, planet.position.y, 0]
                )
                
                //angular velocity is 2pi / period
                let angularVelocity = angularSpace / parameters.period
                angles[index] -= 0.002 * Float(angularVelocity)
            }
        }
    }
}
