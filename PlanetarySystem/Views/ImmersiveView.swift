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
    
    @State private var textEntity: ModelEntity?
    @State private var timer: Timer?
    @State private var planetTimer: Timer?
    @Binding var duration: Int
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
                
                // Create initial text entity
                let initialText = duration == 60 ? minuteArray[currentStep] : threeMinutesArray[currentStep]
                let newTextEntity = createTextEntity(text: initialText)
                
                
                newTextEntity.position = SIMD3(x: -1.5, y: 1.1, z: -2)
                newTextEntity.components.set(ImageBasedLightComponent(source: .single(environment)))
                newTextEntity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: planet))
                newTextEntity.components.set(GroundingShadowComponent(castsShadow: true))
                
                content.add(newTextEntity)
                content.add(planet)
                
                // Store reference to text entity
                textEntity = newTextEntity
                
                // Start timer for updating text
                startTimer(entity: planet)
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
    
    private func startTimer(entity: Entity) {
        timer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { _ in
            
            updateStep()
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
    
    private func updateStep() {
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
        
        // Update text entity
        updateTextEntity(newText)
    }
    
    
    private func updateTextEntity(_ text: String) {
        guard let textEntity = textEntity else {
            print("Error: Text entity is nil")
            return
        }
        
        // Create mesh for the new text
        let mesh = MeshResource.generateText(text, extrusionDepth: 0.1, font: .systemFont(ofSize: 0.2), containerFrame: .zero, alignment: .center, lineBreakMode: .byWordWrapping)
        
        // Set the new mesh for the text entity
        textEntity.model?.mesh = mesh
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
