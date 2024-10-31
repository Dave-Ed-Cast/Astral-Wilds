//
//  PlanetsDIY.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 13/05/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct MovePlanetsYouChoose: View {
    
    @Environment(\.setMode) var setMode
    
    @State private var timers: [String: Timer] = [:]
    @State private var planetName: Entity? = nil
    
    @State private var orbitalParameters = PlanetParameters.list
    
    var body: some View {
        
        
        //the reality view
        RealityView { content in
            
            //skybox creation
            guard let skyBoxEntity = content.createSkyBox() else {
                print("error")
                return
            }
            
            content.add(skyBoxEntity)
            
            //scene with planets and light
            if let scene = try? await Entity(named: "Planets", in: realityKitContentBundle), let environment = try? await EnvironmentResource(named: "studio") {
                
                scene.components.set(ImageBasedLightComponent(source: .single(environment)))
                scene.components.set(ImageBasedLightReceiverComponent(imageBasedLight: scene))
                scene.components.set(GroundingShadowComponent(castsShadow: true))
                
                content.add(scene)
            }
        }
        //define the gesture to target one entity randomly
        .gesture(SpatialTapGesture(coordinateSpace: .local).targetedToAnyEntity().onEnded({ value in
            //discover which entity was touched
            let planet = planetName(for: value.entity, in: value.entity.name)
            planetName = planet
            //and move it
            movePlanet(entity: planet!)
        }))
        .gesture(RotateGesture3D().onEnded({ value in
            
            if let planet = planetName {
                rotatePlanetGesture(entity: planet, rotation: value.rotation)
            }
        }))
    }
    
    private func rotatePlanetGesture(entity: Entity, rotation: Rotation3D) {
        let angle = rotation.angle
        let axis = rotation.axis
        let simdRotation = simd_quatf(angle: Float(angle.radians), axis: [Float(axis.x), Float(axis.y), Float(axis.z)])
        entity.transform.rotation *= simdRotation
    }
    
    private func rotatePlanet(entity: Entity, angle: Angle) {
        let rotation = simd_quatf(angle: Float(angle.radians), axis: [0, 1, 0])
        entity.transform.rotation *= rotation
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
    
    private func startMovement(for entity: Entity, with parameters: PlanetCharacteristic) {
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
            
            let rotationAngle = (Float(0.005 / Float.random(in: 4...12)))
            entity.transform.rotation *= simd_quatf(
                angle: (entity.name == "Venus" || entity.name == "Uranus") ? rotationAngle : -rotationAngle,
                axis: [0, entity.position.y, 0]
            )
        }
        
        //store the timer associated with the entity
        timers[entity.name] = timer
    }
    
    //stop movement for the  planet
    private func stopMovement(for entity: Entity) {
        guard let timer = timers[entity.name] else { return }
        timer.invalidate()
        timers[entity.name] = nil
    }
    
    /// Finds the planet name through Depth First Search method
    ///
    /// - Parameters:
    ///   - scene: for the particular entity
    ///   - name: in the dictionary
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
