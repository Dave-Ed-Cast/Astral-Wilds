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
    
    var body: some View {
        
        Button {
            Task {
                await dismissImmersiveSpace()
            }
            
        } label: {
            Text("Go back to the menu")
        }
        .padding()
        
        RealityView { content in
            
            guard let skyBoxEntity = createSkyBox() else {
                print("error")
                return
            }
            
            let planet = try? await Entity(named: "TravelToMars", in: realityKitContentBundle)
            
            content.add(skyBoxEntity)
            content.add(planet!)
        }
        .onAppear {
            //but before that let's get rid of everything else
            dismissWindow(id: "main")
        }
    }
}

#Preview {
    ImmersiveView()
}
