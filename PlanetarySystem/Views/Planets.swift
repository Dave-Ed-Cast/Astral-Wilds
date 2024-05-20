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
    
    //declare the environment to dismiss everything useless
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace

    //working with numbers is boring so let's define some references in the other file (Parameters)
    
    //this is an array initialized in a random way so that
    @State private var angles: [Float] = {
        var anglesArray: [Float] = []
        for _ in 0..<8 {
            let randomValue = Float.random(in: 1...10)
            anglesArray.append(.pi * randomValue)
        }
        return anglesArray
    }()

    var body: some View {
        //create the reality view
        
        Button {
            Task {
                await dismissImmersiveSpace()
            }
        } label: {
            Text("Go back to the menu")
        }
        .frame(width: 250, height: 100)
        .padding()
        .padding(.bottom, 3000)
        .padding(.horizontal, 1000)
        
        RealityView { content in
            
            guard let skyBoxEntity = createSkyBox() else {
                print("error")
                return
            }
                content.add(skyBoxEntity)
            
            //define the scene
            if let scene = try? await Entity(named: "Planets", in: realityKitContentBundle), let environment = try? await EnvironmentResource(named: "studio") {
                
                    scene.components.set(ImageBasedLightComponent(source: .single(environment)))
                    scene.components.set(ImageBasedLightReceiverComponent(imageBasedLight: scene))
                    scene.components.set(GroundingShadowComponent(castsShadow: true))
                    content.add(scene)
                    
                    //and let the solar system go!
                    startAnimationLoop(entity: scene)
            }
            
        }
        .onAppear {
            withAnimation(.linear) {
                dismissWindow(id: "main")
            }
        }
    }
    
    //start animation loop
    private func startAnimationLoop(entity: Entity) {
        
        //this is like the function update in game engines
        Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in
            
            //now the fun part. For every element we have to define the orbit
            //to do so define an index to keep track of the position, and an angle that defines the value of the array we declared
            for (index, angle) in angles.enumerated() {
                
                //define parameters regarding the other file (at the index)
                let parameters = orbitalParameters[index]
                
                //well, this is just some math, the definition of x and z (which in this case would be our famous y if we were in a 2D world)
                let x = parameters.radius * cos(angle)
                let z = parameters.radius * sin(angle)
                
                //define the new position regarding these new parameters and with y = 1 due to the fact that in reality composer i put everything at y = 1
                let newPosition = SIMD3(x, 1.5, z)
                
                //then since for some reason by doing $0.name, it would get the entity name as root, i created a function that returns the planet's name, and if those match, it gives it the new position
                if let planet = planetName(scene: entity, name: planetDictionary[index]) {
                    planet.position = newPosition
                }
                
                //then this is basic phyisics, if we didn't define the angular velocity, the period would be completely messed up, in fact without this the higher the period, the faster it would revolve (which is completely wrong)
                let angularVelocity = 2 * .pi / parameters.period
                
                //and everytime it's called, just sum this value
                angles[index] -= 0.001 * Float(angularVelocity)
                let rotationAngle = (Float(0.005 / parameters.radius))
                entity.transform.rotation *= simd_quatf(
                    angle: (entity.name == "Venus" || entity.name == "Uranus") ? rotationAngle : -rotationAngle,
                    axis: [0, entity.position.y, 0]
                )
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
