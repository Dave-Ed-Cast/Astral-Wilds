//
//  TravelToMars.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 15/05/24.
//

import SwiftUI
import ARKit
import RealityKit
import RealityKitContent
import VisionTextArc

/// Like in the other immersive spaces, we need to first create the skybox.
/// Then, we need to load the associated scene with the lights.
struct ImmersiveTravel: View {
    
    @Environment(GestureModel.self) private var gestureModel
    @Environment(\.setMode) private var setMode
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @Binding var duration: Int
    
    @StateObject private var travel = ImmersiveTravelController()
    
    @State private var audioPlayer: AudioPlayer = AudioPlayer.shared
    
    private var selectedMode: String {
        return duration == 0 ? "TravelToMarsShort" : "TravelToMarsLong"
    }
    
    let configuration = TextCurver.Configuration(
        radius: 3.5,
        yPosition: 1.1
    )
    
    var textArray: [String] {
        let text = TextArray()
        return duration == 0 ? text.minuteArray : text.threeMinutesArray
    }
    
    var body: some View {
        
        RealityView { content in
#if !targetEnvironment(simulator)
            Task {
                await gestureModel.startTrackingSession()
                await gestureModel.updateTracking()
            }
#endif
            let localContent = content
            
            //This is safe to unwrap, it's for readability to write like this
            if let planet = try? await Entity(named: selectedMode, in: realityKitContentBundle) {
                let environment = try? await EnvironmentResource(named: "studio")
                
                planet.configureLighting(resource: environment!, withShadow: true, for: planet)
                
                content.add(planet)
                
                await startTravel(content: localContent, environment: environment!)
            }
        }
#if !targetEnvironment(simulator)
        .onChange(of: gestureModel.isSnapGestureActivated) { _, isActivated in
            if isActivated {
                Task { await setMode(.mainScreen) }
            }
        }
#endif
        
        .onAppear { audioPlayer.playSong() }
        .onDisappear { audioPlayer.stopSong() }
    }
    
    private func startTravel(content: RealityViewContent, environment: EnvironmentResource?) async {
                
        await travel.createText(
            textConfig: configuration,
            textArray: textArray,
            content: content
        )
        
        travel.startParticles(environment: environment!) { newParticle in
            content.add(newParticle)
        }
        
        travel.moveParticles()
    }
    
}
