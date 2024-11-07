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
                planet.components.set(ImageBasedLightComponent(source: .single(environment!)))
                planet.components.set(ImageBasedLightReceiverComponent(imageBasedLight: planet))
                planet.components.set(GroundingShadowComponent(castsShadow: true))
                startTimers(entity: planet, environment: environment!, content: content)
                content.add(planet)
                
            }
        }
            
        .onAppear {
            audioPlayer.playSong(
                "space",
                dot: "mp3",
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
        
        let updateInterval: TimeInterval = 10 / 90.0
        let updateTextInterval: TimeInterval = 5.0
        let newParticleInterval: TimeInterval = 0.2

        
        timer = Timer.scheduledTimer(withTimeInterval: updateTextInterval, repeats: true) { _ in
            
            //grab the text given the duration selected
            let text = duration == 60 ? textArray.minuteArray[currentStep] : textArray.threeMinutesArray[currentStep]
            
            //update the index (we give parameters because it could be done here but to improve readability i created functions
            updateStep(duration: duration)
            updateTextEntities(text, environment: environment, referenceEntity: entity)
            
            //create the curved text entity
            textEntities = createCurvedTextEntities(text: text, environment: environment, referenceEntity: entity)
            
            //then add it to the view
            for entity in textEntities {
                content.add(entity)
            }
            
        }
        
        particleTimer = Timer.scheduledTimer(withTimeInterval: newParticleInterval, repeats: true) { _ in
            
            guard spawnParticle else { return }
            
            //create the particles with lighting
            let particleEntity = content.createParticle()
            particleEntity.components.set(ImageBasedLightComponent(source: .single(environment)))
            particleEntity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: entity))
            particleEntity.components.set(GroundingShadowComponent(castsShadow: true))
            particles.append(particleEntity)
            content.add(particleEntity)
            
        }
        
        let particleSpeed: Float = 0.015
        moveParticleTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in

            for particleEntity in particles {
                particleEntity.position.z += particleSpeed
                
                if particleEntity.position.z > 23 {
                    particleEntity.removeFromParent()
                    
                    // Remove particle from the list to prevent memory overload
                    if let index = particles.firstIndex(of: particleEntity) {
                        particles.remove(at: index)
                    }
                }
            }
        }
        
        //also start the planet timer to make it go towards the user
        planetTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { timer in
            entity.position.z += (duration == 60) ? 0.00089 : 0.000425
            let rotationAngle = (Float(0.00005))
            let rotationDirection = -1.0
            //also make it rotate
            entity.transform.rotation *= simd_quatf(
                angle: Float(rotationDirection) * rotationAngle,
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
    
    //this is the update
    private func updateTextEntities(_ text: String, environment: EnvironmentResource, referenceEntity: Entity) {
        //remove old entities from the content
        for entity in textEntities {
            entity.removeFromParent()
        }
        
        //create new text entities
        let newTextEntities = createCurvedTextEntities(text: text, environment: environment, referenceEntity: referenceEntity)
        textEntities = newTextEntities
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
        var currentAngle: Float = -1.9
        
        // Second pass: Create and position each character
        for char in text {
            let charEntity = createTextEntity(text: String(char))
            
            if let boundingBox = charEntity.model?.mesh.bounds {
                let characterWidth = boundingBox.extents.x
                let angleIncrement = (characterWidth + letterPadding) / radius
                
                // Calculate the position on the curve
                let x = radius * cos(currentAngle)
                let z = radius * sin(currentAngle) - 2.0
                charEntity.position = SIMD3(x, yPosition, z)
                
                // Rotate the character to face inward along the curve
                // Direction of the character's rotation (look towards the center of the curve)
                let lookAtDirection = SIMD3(-x, 0, -z) // The vector pointing towards the origin (0, 0, 0)
                
                // Use the look-at approach to orient the character
                charEntity.orientation = simd_quatf(from: SIMD3(0, 0, 1), to: lookAtDirection)
                
                // Move to the next angle
                currentAngle += angleIncrement
                
                // Add brightness and shadow components
                charEntity.components.set(ImageBasedLightComponent(source: .single(environment)))
                charEntity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: referenceEntity))
                charEntity.components.set(GroundingShadowComponent(castsShadow: true))
                
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
