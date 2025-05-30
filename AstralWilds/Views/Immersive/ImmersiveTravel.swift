//
//  TravelToMars.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 15/05/24.
//

import SwiftUI
import RealityKit
import RealityKitContent
import VisionTextArc
import AVFAudio

/// Like in the other immersive spaces, we need to first create the skybox.
/// Then, we need to load the associated scene with the lights.
struct ImmersiveTravel: View {
    
    @Environment(\.setMode) private var setMode
    
    @Binding var duration: Int
    @Binding var sitting: Bool
    
    @State private var travel = ImmersiveTravelController()
    @State private var player = AudioPlayer()
    @State private var enableGestures = false
    
    let fixedZPosition: Float = -1.5
    
    private var selectedMode: String {
        return duration == 0 ? "TravelToMarsShort" : "TravelToMarsLong"
    }
    
    private var selectedStance: Float {
        return sitting ? 1.1 : 1.6
    }
    
    private var textArray: [String] {
        return duration == 0 ? TextArray().minuteArray : TextArray().threeMinutesArray
    }
    
    var body: some View {
        
        RealityView { view in
#if !targetEnvironment(simulator)
            addHands(in: content)
#endif
            //This is safe to unwrap, it's for readability to write like this
            if let scene = try? await Entity(named: selectedMode, in: realityKitContentBundle) {
                
                player.entityHolder = scene
                travel.sceneHolder = scene
                let environment = try? await EnvironmentResource(named: "studio")
                scene.configureLighting(resource: environment!, withShadow: true, for: scene)
                await startTravel(view: view, entity: scene)
                
                view.add(scene)
            }
        } placeholder: {
            Text("Opening immersive space...")
            ProgressView()
                .font(.title3)
                .position(x: 150, y: 150)
        }
        .onAppear { travel.textArray = textArray }
        .onAppear { travel.duration = duration }
        // MARK: To be fixed
        //        .installGestures()
        //        .disabled(!enableGestures)
        //        .onAppear {
        //            Task {
        //                let sleepDuration = duration == 0 ? 55 : 175
        //                try? await Task.sleep(for: .seconds(sleepDuration))
        //                enableGestures = true
        //            }
        //        }
        
#if !targetEnvironment(simulator)
        .onChange(of: GestureRecognizer.shared.didThanosSnap) { _, isActivated in
            if isActivated {
                await MainActor.run {
                    await setMode(.mainScreen)
                    GestureRecognizer.shared.resetSnapState()
                }
            }
        }
#endif
        
    }
    
    private func startTravel(view: RealityViewContent, entity: Entity) async {
        
        let configuration = TextCurver.Configuration(
            fontSize: 0.1,
            radius: 4,
            yPosition: selectedStance
        )
        
        travel.createText(textArray, config: configuration, view: view)
        travel.particleEmitter()
        player.playAudio("SpaceMusic")
    }
    
    @MainActor
    private func addHands(in content: any RealityViewContentProtocol) {
        // Add the left hand.
        let leftHand = Entity()
        leftHand.components.set(HandTrackingComponent(chirality: .left))
        content.add(leftHand)
        
        // Add the right hand.
        let rightHand = Entity()
        rightHand.components.set(HandTrackingComponent(chirality: .right))
        content.add(rightHand)
    }
}

