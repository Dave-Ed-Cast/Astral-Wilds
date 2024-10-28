//
//  Planets.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

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
        
        ZStack {
            BackToRealityButtonView()
                .fixedSize(horizontal: true, vertical: false)
                .environment(\.setMode, setMode)
                .padding()
            
            RealityView { content in
                //define the skybox
                guard let skyBoxEntity = content.createSkyBox() else {
                    return
                }
                content.add(skyBoxEntity)
                
                //define the scene
                if let scene = try? await Entity(named: "Planets", in: realityKitContentBundle), let environment = try? await EnvironmentResource(named: "studio") {
                    
                    //define the environment
                    scene.components.set(ImageBasedLightComponent(source: .single(environment)))
                    scene.components.set(ImageBasedLightReceiverComponent(imageBasedLight: scene))
                    scene.components.set(GroundingShadowComponent(castsShadow: true))
                    content.add(scene)
                    
                    //and now it's time to move the planets
                    startAnimationLoop(entity: scene)
                }
            }
        }
    }
    
    /// Given the entity as an input, the function will make it move according to math formulas
    /// - Parameter entity: the entity that will be rotated and will revolve around the sun
    private func startAnimationLoop(entity: Entity) {
        
        //this will be repeated every millisecond
        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in
            //loop through each angle and its corresponding index in the angles array
            for (index, angle) in angles.enumerated() {
                
                //define the parameters for that planet according to the index
                let parameters = orbitalParameters[index]
                let x = parameters.radius * cos(angle)
                let z = parameters.radius * sin(angle)
                let newPosition = SIMD3(x, 1.5, z)
                
                //then if we found it in the dictionary we can move it
                if let planet = planetName(scene: entity, name: planetDictionary[index]) {
                    planet.position = newPosition
                    let rotationAngle = (Float(0.005 / Float.random(in: 4...12)))
                    let rotateClockwise = (planet.name == "Venus" || planet.name == "Uranus")
                    let rotationDirection: Float = rotateClockwise ? 1.0 : -1.0
                    
                    //update rotation
                    planet.transform.rotation *= simd_quatf(
                        angle: rotationDirection * rotationAngle,
                        axis: [0, planet.position.y, 0] 
                    )
                }

                
                //define the revolving action
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
