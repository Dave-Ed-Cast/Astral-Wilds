//
//  TravelToMars.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 15/05/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import VisionTextArc
import AVFAudio

/// Like in the other immersive spaces, we need to first create the skybox.
/// Then, we need to load the associated scene with the lights.
struct ImmersiveTravel: View {
    
    @StateObject private var travel = ImmersiveTravelController()
    
    @Environment(GestureModel.self) private var gestureModel
    @Environment(\.setMode) private var setMode
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @Binding var duration: Int
    @Binding var sitting: Bool
        
    private var selectedMode: String {
        return duration == 0 ? "TravelToMarsShort" : "TravelToMarsLong"
    }
    
    private var selectedStance: Float {
        return sitting ? 1.1 : 1.6
    }
    
    private var textArray: [String] {
        return duration == 0 ? TextArray().minuteArray : TextArray().threeMinutesArray
    }
    
    var body: some View {
        
        /// `This is not good practice!`
        /// It was implemented at some point because I didn't understand how to factor inside my functions the `inout` parameter that is the reality view.
        ///
        /// Creating a copy of the reality view, only if truly needed, demands to be done at the start, so it is almost empty.
        /// In a way, it is like creating another reality view on top of the original one, which is not recommended overall.
        ///
        /// However, there are some cases where this could be useful, for example if the reality view doesn't load any scenes, or light ones.
        ///
        /// It is imperative, generally, to avoid using copies of the reality views, especially if they are heavy! They impact performance!
        ///
        /// `let localContent = view` <- is the copy
        
        RealityView { view in
            
#if !targetEnvironment(simulator)
            //Without task it cannot load the view because it will keep waiting for t
            Task.detached(priority: .low) {
                await gestureModel.startTrackingSession()
                await gestureModel.updateTracking()
            }
#endif
           
            //This is safe to unwrap, it's for readability to write like this
            if let scene = try? await Entity(named: selectedMode, in: realityKitContentBundle) {
                
                let environment = try? await EnvironmentResource(named: "studio")
                scene.configureLighting(resource: environment!, withShadow: true, for: scene)
                await startTravel(view: view, entity: scene)
                
                view.add(scene)
            }
        } placeholder: {
            Text("Opening immersive space...")
            ProgressView()
                .font(.largeTitle)
                .position(x: 150, y: 150)
        }
//        .installGestures()
        
#if !targetEnvironment(simulator)
        .onChange(of: gestureModel.didThanosSnap) { _, isActivated in
            if isActivated {
                Task { await setMode(.mainScreen) }
            }
        }
#endif
        .onAppear { travel.textArray = textArray }
    }
    
    private func startTravel(view: RealityViewContent, entity: Entity) async {
        
        let configuration = TextCurver.Configuration(
            fontSize: 0.1,
            radius: 3.5,
            yPosition: selectedStance
        )
        
        travel.createText(textArray, config: configuration, view: view)
        travel.startParticles(view: view)
        travel.moveParticles()
        
        guard let music = entity.findEntity(named: "SpaceMusic") else {
            print("audio holder not found")
            return
        }
        
        guard let audioLibrary = music.components[AudioLibraryComponent.self] else {
            print("audio library not found")
            return
        }
        guard let audioResource = audioLibrary.resources.first?.value else {
            print("music not found")
            return
        }
        entity.playAudio(audioResource)
    }
}

