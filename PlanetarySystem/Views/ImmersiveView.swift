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

struct ImmersiveView: View {
    
    @Environment(\.setMode) var setMode
    
    //duration taken from the user input
    @Binding var duration: Int
    
    //define the variables needed to work for logic
    @State private var spawnParticle: Bool = true
    @State private var textEntities: [ModelEntity] = []
    @State private var timer: Timer?
    @State private var particleTimer: Timer?
    @State private var moveParticleTimer: Timer?
    @State private var planetTimer: Timer?
    @State private var currentStep: Int = 0
    @State private var minuteArray: [String] = [
        "Hello traveler. Please sit and relax",
        "Now let us enjoy the journey to mars",
        "Without weight, embrace the silence",
        "Among stars, infinite possibilities",
        "Breath in, breath out, let it go...",
        "Connect the cosmo and your heartbeat",
        "Time slows down, you transcend space",
        "The universe, it feels cold yet calm",
        "Gravity fades, and we become one...",
        "Here we are... we reached Mars...",
        ""
    ]
    
    //this is for music
    class AudioPlayer {
        static var shared: AVAudioPlayer = AVAudioPlayer()
    }
    
    
    @State private var threeMinutesArray: [String] = [
        "Welcome. Please sit and relax...",
        "Let us enjoy the journey to mars",
        "Without weight, embrace the silence",
        "Through stars, countless possibilities",
        "Breath in, breath out, let it go...",
        "Connect the cosmo and your heartbeat",
        "Time slows down, you transcend space",
        "The universe... it feels cold yet calm",
        "Gravity fades away, and we become one",
        "Drift into the celestial ballet...",
        "Comets dance, planets waltz in silence",
        "Stardust sprinkles, illuminating darkness",
        "Each heartbeat echoes through the void",
        "Deeper into the cosmic embrace...",
        "Light years whisper in the vast expanse",
        "A symphony of colors paints the night sky",
        "Embrace the serenity of eternal night",
        "Constellations tell timeless tales",
        "Your spirit intertwines with the universe",
        "Floating beyond reality and whatnot",
        "Where dreams and stars collide...",
        "Unveil mysteries within the galaxies",
        "You are a voyager of the infinite",
        "Endless odyssey through space wonders",
        "Become boundless and free with the universe",
        "Here we are... we reached Mars...",
        "",
        ""
    ]
    
    var body: some View {
        
        //reality view
        RealityView { content in
            guard let skyBoxEntity = createSkyBox() else {
                print("Error: Unable to create skybox entity")
                return
            }
            content.add(skyBoxEntity)
            
            if let planet = try? await Entity(named: "TravelToMars", in: realityKitContentBundle),
               let environment = try? await EnvironmentResource(named: "studio") {
                planet.components.set(ImageBasedLightComponent(source: .single(environment)))
                planet.components.set(ImageBasedLightReceiverComponent(imageBasedLight: planet))
                planet.components.set(GroundingShadowComponent(castsShadow: true))
                startTimer(entity: planet, environment: environment, content: content)
                content.add(planet)
            }
        }
        
        .onAppear(perform: {
            //instantiate the music that can throw errors
            do {
                if let path = Bundle.main.url(forResource: "space", withExtension: "mp3") {
                    AudioPlayer.shared = try AVAudioPlayer(contentsOf: path)
                    AudioPlayer.shared.numberOfLoops = 0
                    AudioPlayer.shared.volume = 0.25
                    AudioPlayer.shared.play()
                } else {
                    print("File not found.")
                }
            } catch {
                print("Error initializing AVAudioPlayer: \(error)")
            }
        })
        .onDisappear {
            stopTimer()
            AudioPlayer.shared.stop()
        }
    }
    
    //MARK: Functions
    
    //this starts the timer for the journey
    private func startTimer(entity: Entity, environment: EnvironmentResource, content: RealityViewContent) {
        
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            
            particleTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                if spawnParticle {
                    
                    //create the particles with lighting
                    let particleEntity = createParticle()
                    particleEntity.components.set(ImageBasedLightComponent(source: .single(environment)))
                    particleEntity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: entity))
                    particleEntity.components.set(GroundingShadowComponent(castsShadow: true))
                    content.add(particleEntity)
                    //move each particle
                    moveParticleTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { _ in
                        particleEntity.position.z += 0.0025
                        //and erase to avoid stuttering and memory overload
                        if particleEntity.position.z > 25 {
                            particleEntity.removeFromParent()
                        }
                    }
                }
            }
            //grab the text given the duration selected
            let text = duration == 60 ? minuteArray[currentStep] : threeMinutesArray[currentStep]
            
            //update the index (we give parameters because it could be done here but to improve readability i created functions
            updateStep(planet: entity, environment: environment)
            
            //create the curved text entity
            textEntities = createCurvedTextEntities(text: text, environment: environment, referenceEntity: entity)
            
            //then add it to the view
            for entity in textEntities {
                content.add(entity)
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
    
    //this is the continuous for the start timer
    private func updateStep(planet: Entity, environment: EnvironmentResource) {
        if duration == 60 {
            currentStep = (currentStep + 1) % minuteArray.count
            if currentStep == minuteArray.count - 1 {
                stopTimer()
            }
            else if currentStep == minuteArray.count - 2 {
                particleTimer?.invalidate()
                particleTimer = nil
                spawnParticle = false
            }
        } else {
            currentStep = (currentStep + 1) % threeMinutesArray.count
            if currentStep == threeMinutesArray.count - 1 {
                stopTimer()
            }
        }
        
        //get the updated text and update it
        let newText = duration == 60 ? minuteArray[currentStep] : threeMinutesArray[currentStep]
        updateTextEntities(newText, environment: environment, referenceEntity: planet)
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
        //the higher, the more the curve is pronounced
        let radius: Float = 5.9
        //this is the distance of the letters
        let angleIncrement = Float(0.025)
        //fixed position for letters on y
        let yPosition: Float = 1.35
        
        var entities: [ModelEntity] = []
        
        for (index, char) in text.enumerated() {
            //the angle on the curve of characters
            let angle = angleIncrement * Float(index) - Float.pi + 1.2
            
            //calculate the position for the user
            let x = radius * cos(angle) + radius - 6.1
            let z = radius * sin(angle) - (radius * 0.5) + 4
            
            //create the character
            let charEntity = createTextEntity(text: String(char))
            charEntity.position = SIMD3(x, yPosition, z)

            //rotate the letters to give a feeling of curve
            let rotationAngle = -(angle + Float.pi / 2)
            charEntity.orientation = simd_quatf(angle: Float(rotationAngle), axis: SIMD3(0, 1, 0))
            
            //brightness of letters
            charEntity.components.set(ImageBasedLightComponent(source: .single(environment)))
            charEntity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: referenceEntity))
            charEntity.components.set(GroundingShadowComponent(castsShadow: true))
            
            entities.append(charEntity)
        }
        
        return entities
    }
    
    //this creates the text entity
    private func createTextEntity(text: String) -> ModelEntity {
        let mesh = MeshResource.generateText(text, extrusionDepth: 0.1, font: .systemFont(ofSize: 0.17), containerFrame: .zero, alignment: .center, lineBreakMode: .byWordWrapping)
        let material = SimpleMaterial(color: .white, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }
}

#Preview {
    ImmersiveView(duration: .constant(60))
}
