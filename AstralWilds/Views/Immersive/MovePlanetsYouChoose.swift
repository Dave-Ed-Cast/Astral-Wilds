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
    
    @Environment(\.setMode) private var setMode
    
    @State private var player: AudioPlayer = .init()
    @State private var timers: [String: Timer] = [:]
    @State private var selectedPlanetEntity: Entity? = nil
    
    let planetController = PlanetController.shared
    
    var body: some View {
        
        RealityView { content in
#if !targetEnvironment(simulator)
            addHands(in: content)
#endif
            //This is safe to unwrap, it's for readability to write like this
            if let scene = try? await Entity(named: "Planets", in: realityKitContentBundle) {
                player.entityHolder = scene
                player.playAudio("MuseumMusic")
                content.add(scene)
            }
        }
        .installGestures()
        
        .gesture(
            SpatialTapGesture(coordinateSpace: .local)
                .targetedToAnyEntity()
                .onEnded { value in
                    if let planet = planetName(for: value.entity, in: value.entity.name) {
                        selectedPlanetEntity = planet
                        planetController.moveThisPlanet(planet)
                    }
                }
        )
        
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
    private func addHands(in content: any RealityViewContentProtocol) {
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
