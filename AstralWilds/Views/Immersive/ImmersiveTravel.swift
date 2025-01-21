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
import AVFAudio

/// Like in the other immersive spaces, we need to first create the skybox.
/// Then, we need to load the associated scene with the lights.
struct ImmersiveTravel: View {
    
    @Environment(GestureModel.self) private var gestureModel
    @Environment(\.setMode) private var setMode
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @Binding var duration: Int
    
    @StateObject private var travel = ImmersiveTravelController()
    
    @State private var player: AVAudioPlayer? = nil
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
            /// This is not good practice!
            ///
            /// However, creating a copy of this content in this particular point (which is still empty) helps with the creation of the controller class.
            /// it means that the way this has been coded, rather my knowledge, is as far as it goes.
            ///
            /// It is imperative, generally, to avoid using copies of the reality views, especially if they are heavy! They impact performance!
            /// Also, if necessary, copy them always at the earliest possible time.
            let localContent = content
            
#if !targetEnvironment(simulator)
            Task.detached(priority: .background) {
                await gestureModel.startTrackingSession()
                await gestureModel.updateTracking()
            }            
#endif
            
            
            //This is safe to unwrap, it's for readability to write like this
            if let planet = try? await Entity(named: selectedMode, in: realityKitContentBundle) {
                let environment = try? await EnvironmentResource(named: "studio")
                
                planet.configureLighting(resource: environment!, withShadow: true, for: planet)
                
                content.add(planet)
                
                await startTravel(content: localContent, environment: environment!)
                
                travel.moveParticles()
            }
        }
#if !targetEnvironment(simulator)
        .onChange(of: gestureModel.isSnapGestureActivated) { _, isActivated in
            if isActivated {
                Task { await setMode(.mainScreen) }
            }
        }
#endif
        
        .onAppear {
            player = audioPlayer.createPlayer("space", dot: "mp3", numberOfLoops: -1, withVolume: 0.5)
            player?.play()
        }
        .onDisappear {
            player?.stop()
            player = nil
        }
    }
    
    private func startTravel(content: RealityViewContent, environment: EnvironmentResource?) async {
                
        travel.createText(textConfig: configuration, textArray: textArray) { text3D in
            content.add(text3D)
        }
        
        travel.startParticles(environment: environment!) { newParticle in
            content.add(newParticle)
        }
    }
}
