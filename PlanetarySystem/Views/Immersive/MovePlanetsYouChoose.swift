//
//  PlanetsDIY.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 13/05/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

/// Like in the other immersive spaces, we need to first create the skybox.
/// Then, we need to load the associated scene with the lights.
struct MovePlanetsYouChoose: View {
    
    @Environment(\.setMode) var setMode
    
    @State private var timers: [String: Timer] = [:]
    @State private var planetName: Entity? = nil
    @State private var orbitalParameters = PlanetParameters.list
    
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
            }
        }
        .gesture(SpatialTapGesture(coordinateSpace: .local).targetedToAnyEntity().onEnded({ value in
            let planet = planetName(for: value.entity, in: value.entity.name)
            planetName = planet
            
            //safe to unwrap because we find it for sure
            movePlanet(planet!)
        }))

    }
    
    private func movePlanet(_ entity: Entity) {
        
        guard let (index, parameters) = orbitalParameters.enumerated().first(where: { $0.element.planet == entity.name }).map({ ($0.offset, $0.element) }) else {
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
        let rotationAngle: Float = 0.003
        
        let updateInterval: Double = 1.0 / 90.0
        let angularSpace = 2.0 * Float.pi
        let angularVelocity = angularSpace / parameters.period
        
        //define a timer that updates the position
        let timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            
            angle -= rotationAngle * Float(angularVelocity)
            
            let x = parameters.radius * cos(angle)
            let z = parameters.radius * sin(angle)
            
            let newPosition = SIMD3(x, entity.position.y, z)     
            
            entity.position = newPosition
            
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
}





//        .gesture(RotateGesture3D().onEnded({ value in
//
//            if let planet = planetName {
//                rotatePlanetGesture(entity: planet, rotation: value.rotation)
//            }
//        }))

//    private func rotatePlanetGesture(entity: Entity, rotation: Rotation3D) {
//        let angle = rotation.angle
//        let axis = rotation.axis
//        let simdRotation = simd_quatf(angle: Float(angle.radians), axis: [Float(axis.x), Float(axis.y), Float(axis.z)])
//        entity.transform.rotation *= simdRotation
//    }
//
//    private func rotatePlanet(entity: Entity, angle: Angle) {
//        let rotation = simd_quatf(angle: Float(angle.radians), axis: [0, 1, 0])
//        entity.transform.rotation *= rotation
//    }