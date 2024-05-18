//
//  TravelToMars.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 15/05/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    
    @State private var textEntity: ModelEntity?
    @State private var timer: Timer?
    @Binding var duration: Int
    @State private var currentStep: Int = 0
    @State private var minuteArray: [String] = [
        "ciao", "ciao2", "ciao3"
        // Add other meditation steps here
    ]
    
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
        .padding()
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
                
                newTextEntity.components.set(ImageBasedLightComponent(source: .single(environment)))
                newTextEntity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: planet))
                newTextEntity.components.set(GroundingShadowComponent(castsShadow: true))
                
                content.add(newTextEntity)
                content.add(planet)
                
                // Store reference to text entity
                textEntity = newTextEntity
                
                // Start timer for updating text
                startTimer()
            }
        }
        .onAppear {
            withAnimation(.linear) {
                dismissWindow(id: "Before")
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 6.0, repeats: true) { _ in
            updateStep()
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateStep() {
        if duration == 60 {
            currentStep = (currentStep + 1) % minuteArray.count
        } else {
            currentStep = (currentStep + 1) % threeMinutesArray.count
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
        let mesh = MeshResource.generateText(text, extrusionDepth: 0.1, font: .systemFont(ofSize: 0.5), containerFrame: .zero, alignment: .center, lineBreakMode: .byWordWrapping)
        
        // Set the new mesh for the text entity
        textEntity.model?.mesh = mesh
    }
    
    private func createTextEntity(text: String) -> ModelEntity {
        let mesh = MeshResource.generateText(text, extrusionDepth: 0.1, font: .systemFont(ofSize: 0.5), containerFrame: .zero, alignment: .center, lineBreakMode: .byWordWrapping)
        let material = SimpleMaterial(color: .white, isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }
}

#Preview {
    ImmersiveView(duration: .constant(60))
}
