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
struct Planets: View {
    
    @Environment(\.setMode) var setMode
    
    @State private var angles: [Float] = {
        var anglesArray: [Float] = []
        for _ in 0..<8 {
            let randomValue = Float.random(in: 1...10)
            anglesArray.append(.pi * randomValue)
        }
        return anglesArray
    }()
    
    private let planetDictionary: [String] = ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]
    private let orbitalParameters = PlanetParameters.list
    
    var body: some View {
        
        RealityView { content in

            guard let skyBoxEntity = content.createSkyBox() else {
                return
            }
            content.add(skyBoxEntity)
            
            if let scene = try? await Entity(named: "Planets", in: realityKitContentBundle), let environment = try? await EnvironmentResource(named: "studio") {
                
                scene.components.set(ImageBasedLightComponent(source: .single(environment)))
                scene.components.set(ImageBasedLightReceiverComponent(imageBasedLight: scene))
                scene.components.set(GroundingShadowComponent(castsShadow: true))
                content.add(scene)
                
                //and now it's time to move the planets
                startAnimationLoop(entity: scene)
            }
        }
    }
    
    /// Will make the entity move (revolve and rotate) according to math formulas.
    /// Since the rotation happens continuosly, we need a timer that does the rotation every time.
    /// For the definition of video, we are going to repeat everything each millisecond.
    ///
    /// For each angle and index define the parameters, then find the planet associated and modify it.
    /// Most of the formula is trial and error
    /// - Parameter entity: the entity that will be rotated and will revolve around the sun
    private func startAnimationLoop(entity: Entity) {
        
        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in

            for (index, angle) in angles.enumerated() {
                let parameters = orbitalParameters[index]
                let x = parameters.radius * cos(angle)
                let z = parameters.radius * sin(angle)
                let newPosition = SIMD3(x, 0, z)
                
                //this is a dictionary created from developers, safe to unwrap
                let planet = planetName(scene: entity, name: planetDictionary[index])!
                let rotationAngle = (Float(0.005 / Float.random(in: 4...12)))
                let rotateClockwise = (planet.name == "Venus" || planet.name == "Uranus")
                let rotationDirection: Float = rotateClockwise ? 1.0 : -1.0
                
                planet.position = newPosition
                
                planet.transform.rotation *= simd_quatf(
                    angle: rotationDirection * rotationAngle,
                    axis: [0, planet.position.y, 0]
                )
                
                
                
                //angular velocity is 2pi / period
                let angularVelocity = 2 * .pi / parameters.period
                angles[index] -= 0.001 * Float(angularVelocity)
            }
            
        }
    }
    
    //this is just finding the planet given the entities with the DFS method (depth first search)
    //basically it's the data structure of a tree, I don't believe it's the best, but it's a very simple task and not the aim of the project
    private func planetName(scene: Entity, name: String) -> Entity? {
        var tempStack = [scene]
        
        while !tempStack.isEmpty {
            let current = tempStack.removeLast()
            if current.name == name {
                return current
            }
            
            tempStack.append(contentsOf: current.children)
        }
        
        return nil
    }
    
}

#Preview {
    Planets()
}
