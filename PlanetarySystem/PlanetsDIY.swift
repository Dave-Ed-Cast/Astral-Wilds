//
//  PlanetsDIY.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 13/05/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct PlanetsDIY: View {
    
    // Declare the environment to dismiss everything useless
    @Environment(\.dismissWindow) var dismissWindow
    @State private var timers: [String: Timer] = [:]
    
    var body: some View {
        // Create the reality view
        RealityView { content in
            
            if let scene = try? await Entity(named: "Planets", in: realityKitContentBundle), let environment = try? await EnvironmentResource(named: "studio") {

                scene.components.set(ImageBasedLightComponent(source: .single(environment)))
                scene.components.set(ImageBasedLightReceiverComponent(imageBasedLight: scene))
                scene.components.set(GroundingShadowComponent(castsShadow: true))
                
                content.add(scene)
            }
        }
        // Declare the tap gesture to move a selected planet
        .gesture(TapGesture().targetedToAnyEntity().onEnded({ value in
            // When the touch is over, find the planet that has been touched
            let planet = findPlanet(scene: value.entity, name: value.entity.name)
            // And move it
            movePlanet(entity: planet!)
        }))
        .onAppear {
            // But before that let's get rid of everything else
            dismissWindow(id: "main")
        }
    }
    
    private func movePlanet(entity: Entity) {
        
        // Locally define the parameters from the chosen planet
        guard let parameters = orbitalParameters.first(where: { $0.planet == entity.name }) else {
            return
        }
        
        guard let index = orbitalParameters.firstIndex(where: { $0.planet == entity.name }) else {
            return
        }
        
        // Toggle the revolving property for the tapped planet
        orbitalParameters[index].revolving.toggle()
        
        // Start or stop the movement of the tapped planet
        if orbitalParameters[index].revolving {
            startMovement(for: entity, with: parameters)
        } else {
            stopMovement(for: entity)
        }
    }

    private func startMovement(for entity: Entity, with parameters: OrbitalParameters) {
        // Calculate angle for initial position
        var angle = atan2(entity.position.z, entity.position.x)
        
        // Create a timer to continuously update the position
        let timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in

            let angularVelocity = 2 * .pi / parameters.period
            angle += 0.001 * Float(angularVelocity)
            
            let x = parameters.radius * cos(angle)
            let z = parameters.radius * sin(angle)
            
            let newPosition = SIMD3(x, entity.position.y, z)
            entity.position = newPosition
        }
        
        // Store the timer associated with the entity
        timers[entity.name] = timer
    }

    private func stopMovement(for entity: Entity) {
        // Stop movement for the given planet
        guard let timer = timers[entity.name] else { return }
        timer.invalidate()
        timers[entity.name] = nil
    }
    
    private func findPlanet(scene: Entity, name: String) -> Entity? {
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
    PlanetsDIY()
}

#Preview {
    PlanetsDIY()
}
