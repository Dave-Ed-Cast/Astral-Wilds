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
    
    @State private var spawnParticle: Bool = true
    @State private var textEntities: [ModelEntity] = []
    @State private var particles: [Entity] = []
    @State private var timer: Timer?
    @State private var particleTimer: Timer?
    @State private var moveParticleTimer: Timer?
    @State private var planetTimer: Timer?
    @State private var currentStep: Int = 0
    @State private var textArray: TextArray = TextArray()
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
    
    //MARK: Functions
    
    //this starts the timer for the journey
    private func startTimers(entity: Entity, environment: EnvironmentResource, content: RealityViewContent) {
        
        let updateInterval: TimeInterval = 1.0 / 90.0
        let updateTextInterval: TimeInterval = 5.0
        let newParticleInterval: TimeInterval = 0.2
        let particleSpeed: Float = 0.015
        
        let selectedDuration = (duration == 0 ? 60 : 180)
                
        timer = Timer.scheduledTimer(withTimeInterval: updateTextInterval, repeats: true) { _ in
            
            let text = selectedDuration == 60 ? (textArray.minuteArray[currentStep]) : textArray.threeMinutesArray[currentStep]
            
            updateStep(duration: duration)
            updateTextEntities()
            textEntities = createCurvedTextEntities(text: text, environment: environment, referenceEntity: entity)
            
            for text3D in textEntities {
                content.add(text3D)
            }
        }
        
        particleTimer = Timer.scheduledTimer(withTimeInterval: newParticleInterval, repeats: true) { _ in
            
            guard spawnParticle else { return }
            let particleEntity = content.createParticle()
            
            particleEntity.configureLighting(resource: environment, withShadow: true, for: entity)
            particles.append(particleEntity)
            content.add(particleEntity)
        }
        
        moveParticleTimer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in

            for particleEntity in particles {
                particleEntity.position.z += particleSpeed
                
                if particleEntity.position.z > 23 {
                    particleEntity.removeFromParent()
                    
                    if let index = particles.firstIndex(of: particleEntity) {
                        particles.remove(at: index)
                    }
                }
            }
        }
        
        let distanceInPixels = 120
        let velocity = Float(selectedDuration) == 60 ? 2.0 : 0.8
        let updateForMovement: TimeInterval = 1.0 / 60.0
        let frameMovement = velocity * updateForMovement
                
        print("distance in pixels: \(distanceInPixels)")
        print("velocity: \(velocity)")
        print("frame movement: \(frameMovement)")
        
        planetTimer = Timer.scheduledTimer(withTimeInterval: updateForMovement, repeats: true) { timer in
            
            entity.position.z += Float(frameMovement)
            print(entity.position.z)
            
            let rotationAngle = Float(0.005)
            let rotationDirection = Float(-1.0)
            entity.transform.rotation *= simd_quatf(
                angle: rotationDirection * rotationAngle,
                axis: [0, entity.position.y, 0]
            )
        }
    }
    
    //when the journey is over stop everything
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        planetTimer?.invalidate()
        planetTimer = nil
        
    }
        
    private func stopParticles() {
        particleTimer?.invalidate()
        particleTimer = nil
        spawnParticle = false
    }
    
    private func updateStep(duration: Int) {
        
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
    
    private func updateTextEntities() {
        for entity in textEntities {
            entity.removeFromParent()
        }
    }
    
    private func createCurvedTextEntities(text: String, environment: EnvironmentResource, referenceEntity: Entity) -> [ModelEntity] {
        // The higher the radius, the more pronounced the curve
        let radius: Float = 3.0
        // Fixed position for letters on the Y-axis
        let yPosition: Float = 1.35
        // Padding to add some space between characters
        let letterPadding: Float = 0.02
        
        var totalAngularSpan: Float = 0.0
        var entities: [ModelEntity] = []
        
        // First pass: Calculate the total angular span
        for char in text {
            let charEntity = createTextEntity(text: String(char))
            if let boundingBox = charEntity.model?.mesh.bounds {
                let characterWidth = boundingBox.extents.x
                let angleIncrement = (characterWidth + letterPadding) / radius
                totalAngularSpan += angleIncrement
            }
        }
        
        // Adjust the starting angle to center the text
        var currentAngle: Float = -1.8
        
        // Second pass: Create and position each character
        for char in text {
            let charEntity = createTextEntity(text: String(char))
            
            if let boundingBox = charEntity.model?.mesh.bounds {
                let characterWidth = boundingBox.extents.x
                let angleIncrement = (characterWidth + letterPadding) / radius
                
                // Calculate the position on the curve
                let x = radius * cos(currentAngle)
                let z = radius * sin(currentAngle)
                
                charEntity.position = SIMD3(x, yPosition, z)
                
                // Rotate the character to face inward along the curve
                // Direction of the character's rotation (look towards the center of the curve)
                let lookAtDirection = SIMD3(-x, 0, -z) // The vector pointing towards the origin (0, 0, 0)
                
                // Use the look-at approach to orient the character
                charEntity.orientation = simd_quatf(from: SIMD3(0, 0, 1), to: lookAtDirection)
                
                // Move to the next angle
                currentAngle += angleIncrement
                
                charEntity.configureLighting(resource: environment, withShadow: true, for: referenceEntity)
                
                entities.append(charEntity)
            }
        }
        
        return entities
    }

    private func createTextEntity(text: String) -> ModelEntity {
        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.03,
            font: .systemFont(ofSize: 0.12),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        let material = SimpleMaterial(color: UIColor(Color(.white).opacity(0.6)), isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
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
