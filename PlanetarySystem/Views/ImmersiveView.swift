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
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    
    @Binding var duration: Int
    
    @State private var timerStarted: Bool = false
    @State private var textEntities: [ModelEntity] = []
    @State private var timer: Timer?
    @State private var planetTimer: Timer?
    @State private var currentStep: Int = 0
    @State private var minuteArray: [String] = [
        "Welcome, sit and relax...",
        "Let us enjoy the journey to mars...",
        "Without weight... embrace silence",
        "Through the stars, possibilities are infinite",
        "Breath in and breath out...",
        "Connect to the cosmo with the echo of your heartbeat",
        "Time slows down and the mind transcends space...",
        "The universe... it feels cold yet calm",
        "Gravity fades away, and we become one...",
        "Here we are... we reached Mars..."
    ]
    
    class AudioPlayer {
        static var shared: AVAudioPlayer = AVAudioPlayer()
    }
    
    
    @State private var threeMinutesArray: [String] = [
        "Ciao",
        // Add other meditation steps here
    ]
    
    var body: some View {
        
        Button {
            Task {
                await dismissImmersiveSpace()
            }
        } label: {
            Text("Go back to reality")
                .font(.title3)
        }
        .frame(width: 250, height: 100)
        .padding()
        .padding(.bottom, 750)
        .padding(.horizontal, 950)
        .opacity(0.5)
        
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
            withAnimation(.linear) {
                dismissWindow(id: "Before")
            }
            
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
    
    private func startTimer(entity: Entity, environment: EnvironmentResource, content: RealityViewContent) {
        timer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { _ in
            let text = duration == 60 ? minuteArray[currentStep] : threeMinutesArray[currentStep]
            updateStep(planet: entity, environment: environment)
            textEntities = createCurvedTextEntities(text: text, environment: environment, referenceEntity: entity)

            for entity in textEntities {
                content.add(entity)
            }
            
        }
        
        planetTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true, block: { timer in
            entity.position.z += (duration == 60) ? 0.001 : 0.0002;
        })
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        planetTimer?.invalidate()
        planetTimer = nil
    }
    
    private func updateStep(planet: Entity, environment: EnvironmentResource) {
        if duration == 60 {
            currentStep = (currentStep + 1) % minuteArray.count
            if currentStep == minuteArray.count - 1 {
                stopTimer()
            }
        } else {
            currentStep = (currentStep + 1) % threeMinutesArray.count
            if currentStep == threeMinutesArray.count - 1 {
                stopTimer()
            }
        }
        
        // Get the updated text
        let newText = duration == 60 ? minuteArray[currentStep] : threeMinutesArray[currentStep]
        
        // Update text entities
        updateTextEntities(newText, environment: environment, referenceEntity: planet)
    }
    
    private func updateTextEntities(_ text: String, environment: EnvironmentResource, referenceEntity: Entity) {
        // Remove old entities from the content
        for entity in textEntities {
            entity.removeFromParent()
        }
        
        // Create new text entities
        let newTextEntities = createCurvedTextEntities(text: text, environment: environment, referenceEntity: referenceEntity)
        textEntities = newTextEntities
    }
    
    private func createCurvedTextEntities(text: String, environment: EnvironmentResource, referenceEntity: Entity) -> [ModelEntity] {
        let radius: Float = 2.0 // Radius to make the curve less pronounced
        let angleIncrement = Float.pi / Float(text.count - 1)
        let yPosition: Float = 1.2 // Fixed y-position
        let zOffset: Float = -radius // Place text in front of the user by adjusting the z-offset
        let xOffset: Float = 2 // Shift text to the left
        let rotationSpeed: Float = 0.9
        
        var entities: [ModelEntity] = []
        
        for (index, char) in text.enumerated() {
            let angle = angleIncrement * Float(index) - Float.pi // Angle for each character
            
            // Calculate positions to ensure text is in front of the user and shifted to the left
            let x = radius * cos(angle) - xOffset // Subtract xOffset to shift left
            let z = radius * sin(angle) + zOffset
            
            let charEntity = createTextEntity(text: String(char))
            charEntity.position = SIMD3(x, yPosition, z)
            
            // Rotate the character to face inward towards the user
            let rotationAngle = 0.5 * rotationSpeed // Adjust to face the user inward
            charEntity.orientation = simd_quatf(angle: Float(-rotationAngle), axis: SIMD3(0, 1, 0))
            
            // Apply environment-based lighting and shadow components
            charEntity.components.set(ImageBasedLightComponent(source: .single(environment)))
            charEntity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: referenceEntity))
            charEntity.components.set(GroundingShadowComponent(castsShadow: true))
            
            entities.append(charEntity)
        }
        
        return entities
    }
    
    
    private func createTextEntity(text: String) -> ModelEntity {
        let mesh = MeshResource.generateText(text, extrusionDepth: 0.1, font: .systemFont(ofSize: 0.2), containerFrame: .zero, alignment: .center, lineBreakMode: .byWordWrapping)
        let material = SimpleMaterial(color: .white, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }
}

#Preview {
    ImmersiveView(duration: .constant(60))
}
