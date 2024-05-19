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
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @State private var immersiveSpaceID: String? = nil
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                Text("Welcome! Choose what do you want to explore")
                    .font(.largeTitle)
                Button {
                    Task {
                        //this is an async call (call when ready)
                        await openImmersiveSpace(id: "planets")
                    }
                } label: {
                    Text("View the solar system")
                        .font(.title2)
                    
                }
                
                Button {
                    Task {
                        //this is an async call (call when ready)
                        await openImmersiveSpace(id: "DIY")
                    }
                } label: {
                    Text("Explore the power of moving the chosing which planet to move")
                        .font(.title2)
                }
                
                Button {
                    openWindow(id: "Before")
                } label: {
                    Text("Engage in a meditation journey to mars")
                        .font(.title2)
                }
                
            }
            .padding()
            .navigationTitle("Space travelling app")
            .navigationBarTitleDisplayMode(.automatic)
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
