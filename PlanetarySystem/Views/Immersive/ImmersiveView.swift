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

/// Like in the other immersive spaces, we need to first create the skybox.
/// Then, we need to load the associated scene with the lights.
struct ImmersiveView: View {

    @Environment(\.setMode) var setMode
    
    @Binding var duration: Int
    
    @State var spawnParticle: Bool = true
    @State var textEntities: [ModelEntity] = []
    @State var particles: [Entity] = []
    @State var timer: Timer?
    @State var particleTimer: Timer?
    @State var moveParticleTimer: Timer?
    @State var planetTimer: Timer?
    @State var currentStep: Int = 0
    @State var textArray: TextArray = TextArray()
    @State private var audioPlayer: AudioPlayer = AudioPlayer.shared
        
    var body: some View {
        
        RealityView { content in
            let skyBoxEntity = content.createSkyBox()
            content.add(skyBoxEntity)
            
            //This is safe to unwrap, it's for readability to write like this
            if let planet = try? await Entity(named: "TravelToMars", in: realityKitContentBundle) {
                let environment = try? await EnvironmentResource(named: "studio")
                planet.configureLighting(resource: environment!, withShadow: true)
                
                //this is so that it spawns where intended given async loading
                planet.position = SIMD3(x: planet.position.x, y: planet.position.y, z: -51)
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
    
    private func startTimers(entity: Entity, environment: EnvironmentResource, content: RealityViewContent) {
        
        textTimer(entity: entity, environment: environment, content: content)
        createNewParticle(entity: entity, environment: environment, content: content)
        movePlanet(entity: entity)
        moveParticles()
        
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        planetTimer?.invalidate()
        planetTimer = nil
        
    }
    
    func updateStep(duration: Int) {
        
        let currentArray = (duration == 0) ? textArray.minuteArray : textArray.threeMinutesArray
        
        currentStep = (currentStep + 1) % currentArray.count
        
        let lastStep = (currentStep == currentArray.count - 1)
        let secondToLast = (currentStep == currentArray.count - 2)
        
        if lastStep {
            stopTimer()
        } else if secondToLast {
            stopParticles()
        }
    }
}

//            if let ambientAudio = try? await Entity(named: "AudioController", in: realityKitContentBundle) {
//
//                let ambientAudioEntityController = ambientAudio.findEntity(named: "AmbientAudio")
//                let audioFileName = "/Root/space"
//
//                guard let resource = try? await AudioFileResource(named: audioFileName, from: "AudioController.usda", in: realityKitContentBundle) else {
//                    fatalError("Unable to load audio resource")
//                }
//                let audioController = ambientAudioEntityController?.prepareAudio(resource)
//                audioController?.play()
//                content.add(ambientAudio)
//            }
