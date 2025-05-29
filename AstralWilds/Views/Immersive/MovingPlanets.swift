//
//  Planets.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

import SwiftUI
import ARKit
import RealityKit
import RealityKitContent

/// Like in the other immersive spaces, we need to first create the skybox.
/// Then, we need to load the associated scene with the lights.
struct MovingPlanets: View {
    
    @Environment(\.setMode) private var setMode
    
    @State private var player: AudioPlayer = .init()
    
    var body: some View {
        
        RealityView { content in
#if !targetEnvironment(simulator)
           
#endif
            //This is safe to unwrap, it's for readability to write like this
            if let planets = try? await Entity(named: "MovingPlanets", in: realityKitContentBundle) {
                player.entityHolder = planets
                player.playAudio("MuseumMusic")
                content.add(planets)
            }
        }
#if !targetEnvironment(simulator)
        
#endif
    }
}
