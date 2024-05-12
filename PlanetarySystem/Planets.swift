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
    
    @Environment(\.dismissWindow) var dismissWindow
    
    let planetDictionary: [String] = ["Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"]
    // Define orbital parameters for each planet
    let orbitalParameters: [OrbitalParameters] = [
        OrbitalParameters(radius: 1.0, period: 3.0),
        OrbitalParameters(radius: 3.0, period: 5.0),
        OrbitalParameters(radius: 5.0, period: 7.0),
        OrbitalParameters(radius: 7.0, period: 9.0),
        OrbitalParameters(radius: 10.0, period: 10.0),
        OrbitalParameters(radius: 12.0, period: 12.0),
        OrbitalParameters(radius: 14.0, period: 14.0),
        OrbitalParameters(radius: 16.0, period: 16.0)
        // Add parameters for other planets as needed
    ]
    
    // State variables to store current angles of rotation
    @State private var angles: [Float] = Array(repeating: 0.0, count: 8)
    
    var body: some View {
        RealityView { content in
            
            if let scene = try? await Entity(named: "Planets", in: realityKitContentBundle) {
                content.add(scene)
                
                // Spawn planets and rotate them around the sun
                if let sun = scene.children.first(
                    where: { $0.name == "Sun" }) {
                    sun.position = .zero
                }
                
                
                // Start animation loop
                startAnimationLoop(scene: scene)
            }
        }
        .onAppear {
            // Dismiss main window
            dismissWindow(id: "main")
        }
    }
    
    // Function to start animation loop
    private func startAnimationLoop(scene: Entity) {
        // Update positions of planets periodically
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            // Apply orbiting motion to each planet
            for (index, angle) in angles.enumerated() {
                let parameters = orbitalParameters[index]
                let x = parameters.radius * cos(angle)
                let y = parameters.radius * sin(angle)
                
                let newPosition = SIMD3(x, y, 0)
                
                // Update position of the planet
                if let planet = findPlanet(scene: scene, name: planetDictionary[index]) {
                    planet.position = newPosition
                }
                
                // Update angle for next frame
                angles[index] += 0.01 * Float(parameters.period)
            }
        }
    }

    // Function to recursively find a planet by name in the scene hierarchy
    private func findPlanet(scene: Entity, name: String) -> Entity? {
        if let planet = scene.children.first(where: { $0.name == name }) {
            return planet
        } else {
            for child in scene.children {
                if let foundPlanet = findPlanet(scene: child, name: name) {
                    return foundPlanet
                }
            }
            return nil
        }
    }

    
    
    
    
    
    
    
    
    
    // Function to start animation loop
//    private func startAnimationLoop(scene: Entity) {
//        
//        print("Entities in scene:")
//            for child in scene.children {
//                print(child.name ?? "Unnamed Entity")
//            }
//        // Update positions of planets periodically
//        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
//            // Apply orbiting motion to each planet
//            for (index, angle) in angles.enumerated() {
//                let parameters = orbitalParameters[index]
//                let x = parameters.radius * cos(angle)
//                let y = parameters.radius * sin(angle)
//                
//                let newPosition = SIMD3(x, y, 0)
//                
//                // Update position of the planet
//                if let planet = scene.children.first(where: { $0.name == "\(planetDictionary[index])" }) {
//                    planet.position = newPosition
//                }
//                
//                print("Planet \(planetDictionary[index]) angle: \(angle)")
//                // Update angle for next frame
//                angles[index] += 0.01 * Float(parameters.period)
//            }
//        }
//    }
}

// Struct to hold orbital parameters for each planet
struct OrbitalParameters {
    let radius: Float // Orbital radius
    let period: Float // Orbital period (time taken to complete one revolution)
}

#Preview {
    Planets()
}
