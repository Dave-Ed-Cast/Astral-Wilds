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
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    
    @State private var timers: [String: Timer] = [:]
    
    var body: some View {
        
        Button {
            Task {
                await dismissImmersiveSpace()
                openWindow(id: "main")
            }
        } label: {
            Text("Go back to reality")
                .font(.title3)
        }
        .frame(width: 250, height: 100)
        .padding()
        .offset(x: 0, y: -1600)
        
        // Create the reality view
        RealityView { content in
            
            guard let skyBoxEntity = createSkyBox() else {
                print("error")
                return
            }
            
            content.add(skyBoxEntity)
            
            if let scene = try? await Entity(named: "Planets", in: realityKitContentBundle), let environment = try? await EnvironmentResource(named: "studio") {

                scene.components.set(ImageBasedLightComponent(source: .single(environment)))
                scene.components.set(ImageBasedLightReceiverComponent(imageBasedLight: scene))
                scene.components.set(GroundingShadowComponent(castsShadow: true))
                
                content.add(scene)
            }
            
            
            
        }
        
        //define the gesture to target one entity randomly
        .gesture(TapGesture().targetedToAnyEntity().onEnded({ value in
            //discover which entity was touched
            let planet = findPlanet(scene: value.entity, name: value.entity.name)
            //and move it
            movePlanet(entity: planet!)
        }))
        .onAppear {
            withAnimation(.linear) {
                dismissWindow(id: "main")
            }
        }
    }
    
    private func movePlanet(entity: Entity) {
        
        //define the two elements we need
        guard let parameters = orbitalParameters.first(where: { $0.planet == entity.name }) else {
            return
        }
        
        guard let index = orbitalParameters.firstIndex(where: { $0.planet == entity.name }) else {
            return
        }
        
        //change the value in the struct so that it's known if it's rotating
        orbitalParameters[index].revolving.toggle()
        
        //and understand what to do according to that
        if orbitalParameters[index].revolving {
            startMovement(for: entity, with: parameters)
            
        } else {
            stopMovement(for: entity)
        }
    }

    private func startMovement(for entity: Entity, with parameters: OrbitalParameters) {
        
        //define the phase, the angle in calculus
        var angle = atan2(entity.position.z, entity.position.x)
        
        //define a timer that updates the position
        let timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in
            
            //same as before
            let angularVelocity = 2 * .pi / parameters.period
            angle -= 0.001 * Float(angularVelocity)
            
            let x = parameters.radius * cos(angle)
            let z = parameters.radius * sin(angle)
            
            let newPosition = SIMD3(x, entity.position.y, z)
            
            entity.position = newPosition
            
            let rotationAngle =  (Float(0.005 / Float.random(in: 4...12)))
            entity.transform.rotation *= simd_quatf(
                angle: (entity.name == "Venus" || entity.name == "Uranus") ? rotationAngle : -rotationAngle,
                axis: [0, entity.position.y, 0]
            )
        }
        
        //store the timer associated with the entity
        timers[entity.name] = timer
    }

    private func stopMovement(for entity: Entity) {
        //stop movement for the  planet
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
