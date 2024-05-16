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
    
    //declare the environment to dismiss everything useless
    @Environment(\.dismissWindow) var dismissWindow
    @State private var timer: Timer? = nil
    //working with numbers is boring so let's define some references in the other file (Parameters)
    var body: some View {
        //create the reality view
        RealityView { content in
            
            //define the scene
            if let scene = try? await Entity(named: "Planets", in: realityKitContentBundle) {
                content.add(scene)
                
            }
        }
        //declare the tap gesture to move a selected planet
        .gesture(TapGesture().targetedToAnyEntity().onEnded({ value in
            //when the touch is over, find the planet that has been touched
            let planet = findPlanet(scene: value.entity, name: value.entity.name)
            //and move it
            movePlanet(entity: planet!)
        }))
    }
    
    private func movePlanet(entity: Entity) {
        
        //locally define the parameters from the chosen planet
        guard let parameters = orbitalParameters.first(where: { $0.planet == entity.name }) else {
            return
        }
        
        guard let index = orbitalParameters.firstIndex(where: { $0.planet == entity.name }) else {
            return
        }
        
        orbitalParameters[index].revolving.toggle()
    
        //we need the angle, so straight outta calculus 1
        var angle = atan2(entity.position.z, entity.position.x)
        
        if !orbitalParameters[index].revolving {
                timer?.invalidate()
                timer = nil // Set the timer to nil to indicate it's not running
                return
            }
        //this is like the function update in game engines, but we move it as long as "var" is true
        if timer == nil {
            
            timer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: orbitalParameters[index].revolving) { _ in
                let angularVelocity = 2 * .pi / parameters.period
                angle += 0.001 * Float(angularVelocity)
                
                let x = parameters.radius * cos(angle)
                let z = parameters.radius * sin(angle)
                
                let newPosition = SIMD3(x, entity.position.y, z)
                entity.position = newPosition
            }
        }
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
