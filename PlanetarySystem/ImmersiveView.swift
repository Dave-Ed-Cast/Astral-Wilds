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
    
    @State var currentStep: Int = 0
    @State var meditationArray: [String] = [
        "click me",
        "ciao2",
        "ciao3",
        "ciao4",
        "ciao5",
        "ciao6",
        "ciao7",
        "ciao8",
        "ciao9",
    ]
    
    
    var body: some View {
        
        Button {
            Task {
                await dismissImmersiveSpace()
            }
        } label: {
            Text("Go back to the menu")
                .font(.title3)
        }
        .padding()
        
        VStack {
            Button {
                currentStep = (currentStep == 10) ? currentStep : currentStep + 1
            } label: {
                withAnimation(.smooth.delay(5)) {
                    Text("\(meditationArray[currentStep])")
                }
            }
        }
        
        RealityView { content in
            
            
            guard let skyBoxEntity = createSkyBox() else {
                print("error")
                return
            }
            
            content.add(skyBoxEntity)
            
            if let planet = try? await Entity(named: "TravelToMars", in: realityKitContentBundle), let environment = try? await EnvironmentResource(named: "studio") {
                
                planet.components.set(ImageBasedLightComponent(source: .single(environment)))
                planet.components.set(ImageBasedLightReceiverComponent(imageBasedLight: planet))
                planet.components.set(GroundingShadowComponent(castsShadow: true))
                
                content.add(planet)
            }
            
            
        }
        .onAppear {
            withAnimation(.linear) {
                dismissWindow(id: "Before")
            }
        }
    }
}

#Preview {
    ImmersiveView()
}
