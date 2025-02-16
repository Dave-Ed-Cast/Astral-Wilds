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
    
    @State private var player: AVAudioPlayer? = nil
    @State private var audioPlayer: AudioPlayer = AudioPlayer.shared
    @State private var textEntity: Entity = Entity()
    
    private var selectedMode: String {
        return duration == 0 ? "TravelToMarsShort" : "TravelToMarsLong"
    }
    
    var textArray: [String] {
        let text = TextArray()
        return duration == 0 ? text.minuteArray : text.threeMinutesArray
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
            await gestureModel.startTrackingSession()
            await gestureModel.updateTracking()
#endif
            
            //This is safe to unwrap, it's for readability to write like this
            if let planet = try? await Entity(named: selectedMode, in: realityKitContentBundle) {
                let environment = try? await EnvironmentResource(named: "studio")
                
                planet.configureLighting(resource: environment!, withShadow: true, for: planet)
                await startTravel(view: view)
                
                view.add(planet)
            }
        } placeholder: {
            Text("Opening immersive space...")
                .font(.extraLargeTitle)
        }
//        .installGestures()
        
#if !targetEnvironment(simulator)
        .onChange(of: gestureModel.didThanosSnap) { _, isActivated in
            if isActivated {
                Task { await setMode(.mainScreen) }
            }
        }
#endif
//        .onAppear {
//            player = audioPlayer.createPlayer(
//                "space",
//                dot: "mp3",
//                numberOfLoops: -1,
//                withVolume: 0.5
//            )
//            player?.play()
//            travel.textArray = textArray
//        }
//        .onDisappear {
//            player?.stop()
//            player = nil
//        }
    }
    
    private func startTravel(view: RealityViewContent) async {
        
        let configuration = TextCurver.Configuration(
            fontSize: 0.1,
            radius: 3.5,
            yPosition: sitting ? 1.1 : 1.6
        )
        
        travel.createText(textArray, config: configuration, view: view)
        travel.startParticles(view: view)
        travel.moveParticles()
    }
}

