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
           addHands(in: content)
#endif
            //This is safe to unwrap, it's for readability to write like this
            if let planets = try? await Entity(named: "MovingPlanets", in: realityKitContentBundle) {
                player.entityHolder = planets
                player.playAudio("MuseumMusic")
                content.add(planets)
            }
        }
#if !targetEnvironment(simulator)
        .onChange(of: GestureRecognizer.shared.didThanosSnap) { _, isActivated in
            if isActivated {
                await MainActor.run {
                    await setMode(.mainScreen)
                    GestureRecognizer.shared.resetSnapState()
                }
            }
        }
#endif
    }
    
    @MainActor
    func addHands(in content: any RealityViewContentProtocol) {
        // Add the left hand.
        let leftHand = Entity()
        leftHand.components.set(HandTrackingComponent(chirality: .left))
        content.add(leftHand)
        
        // Add the right hand.
        let rightHand = Entity()
        rightHand.components.set(HandTrackingComponent(chirality: .right))
        content.add(rightHand)
    }
}
