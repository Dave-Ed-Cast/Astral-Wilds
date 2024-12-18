//
//  TravelToMars.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 15/05/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import AVFoundation
import VisionTextArc

/// Like in the other immersive spaces, we need to first create the skybox.
/// Then, we need to load the associated scene with the lights.
struct ImmersiveView: View {

    @Environment(\.setMode) private var setMode
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @Binding var duration: Int
    
    @State private var audioPlayer: AudioPlayer = AudioPlayer.shared
    
    @State var textEntity: Entity?
    
    @State var timer: Timer?
    @State var particleTimer: Timer?
    @State var moveParticleTimer: Timer?
    @State var planetTimer: Timer?
    
    @State var textEntities: [ModelEntity] = []
    @State var particles: [Entity] = []
    
    @State var spawnParticle: Bool = true
    @State var currentStep: Int = 0
    
    let textCurver = TextCurver.self
    
    var textArray: [String] {
        let textData = TextArray()
        return duration == 0 ? textData.minuteArray : textData.threeMinutesArray
    }
    
    var body: some View {
        
        RealityView { content in
            
            //This is safe to unwrap, it's for readability to write like this
            if let planet = try? await Entity(named: "TravelToMars", in: realityKitContentBundle) {
                let environment = try? await EnvironmentResource(named: "studio")
                
                planet.configureLighting(resource: environment!, withShadow: true, for: planet)
                planet.position = SIMD3(x: planet.position.x, y: planet.position.y, z: -40.0)
                
                startTimers(entity: planet, environment: environment!, content: content)
                content.add(planet)
            }
        }
        
        .onAppear {
            audioPlayer.playSong(
                "space", dot: "mp3",
                numberOfLoops: 0,
                withVolume: 0.25
            )
        }
        .onDisappear {
            stopTimer()
            audioPlayer.stopSong()
        }
    }
    
    /// This is the function tha handles all the timers
    /// - Parameters:
    ///   - entity: entity variable for certain timers
    ///   - environment: environment variable for certain timers
    ///   - content: reality view variable for certain timers
    private func startTimers(
        entity: Entity,
        environment: EnvironmentResource,
        content: RealityViewContent
    ) {
        
        textTimer(environment: environment, content: content)
        createNewParticle(environment: environment, content: content)
        moveParticles()
        movePlanet(entity)
    }
    
    /// Stops all timers
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        planetTimer?.invalidate()
        planetTimer = nil
        
    }
    
    /// Counts the travel steps, and handles the start and finish
    func updateStep() {
                
        currentStep = (currentStep + 1) % textArray.count
        
        let lastStep = (currentStep == textArray.count - 1)
        let thirdToLast = (currentStep == textArray.count - 3)
        
        if lastStep {
            stopTimer()
        }
        
        if thirdToLast {
            stopParticles()
        }
    }
}
