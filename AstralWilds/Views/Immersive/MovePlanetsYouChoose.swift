//
//  PlanetsDIY.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 13/05/24.
//

import SwiftUI
import ARKit
import RealityKit
import RealityKitContent

/// Like in the other immersive spaces, we need to first create the skybox.
/// Then, we need to load the associated scene with the lights.
struct MovePlanetsYouChoose: View {
    
    @Environment(GestureModel.self) private var gestureModel
    @Environment(\.setMode) private var setMode
        
    @State private var timers: [String: Timer] = [:]
    @State private var selectedPlanetEntity: Entity? = nil
    
    let planetController = PlanetController.shared
    
    var body: some View {
                
        RealityView { content in
#if !targetEnvironment(simulator)
            Task {
                await gestureModel.startTrackingSession()
                await gestureModel.updateTracking()
            }
#endif
            //This is safe to unwrap, it's for readability to write like this
            if let scene = try? await Entity(named: "Planets", in: realityKitContentBundle) {
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
        .onChange(of: gestureModel.didThanosSnap) { _, isActivated in
            if isActivated {
                Task { await setMode(.mainScreen) }
            }
        }
#endif        
    }
}
