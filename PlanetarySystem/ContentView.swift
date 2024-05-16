//
//  ContentView.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

//first things first, we declare the container of the immersive space
struct ContentView: View {
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @State private var immersiveSpaceID: String? = nil
    var body: some View {
        
        VStack {
            Button {
                Task {
                    //this is an async call (call when ready)
                    await openImmersiveSpace(id: "planets")
                }
            } label: {
                Text("View the solar system")
            }
            
            Button {
                Task {
                    //this is an async call (call when ready)
                    await openImmersiveSpace(id: "DIY")
                }
            } label: {
                Text("Move the solar system how you want")
            }
            
            Button {
                Task {
                    await openImmersiveSpace(id: "ImmersiveView")
                }
            } label: {
                HStack {
                    Text("Travel to mars")
                    Image(systemName: "visionpro")
                    
                }
            }
        }
        .padding()
        .navigationTitle("Content")
        
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
