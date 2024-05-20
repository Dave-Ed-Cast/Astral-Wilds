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
            VStack(spacing: 20) {
                Text("Welcome! Choose what do you want to explore")
                    .font(.largeTitle)
                HStack {
                    VStack {
                        Image("SolarSystem")
                            .resizable()
                            .frame(width: 350, height: 175)
                            .cornerRadius(20)
                            .padding()
                        Button {
                            Task {
                                //this is an async call (call when ready)
                                await openImmersiveSpace(id: "planets")
                            }
                        } label: {
                            Text("View the solar system")
                                .font(.title2)
                        }
                    }
                    VStack {
                        Image("Touch")
                            .resizable()
                            .frame(width: 350, height: 175)
                            .cornerRadius(20)
                            .padding()
                        Button {
                            Task {
                                //this is an async call (call when ready)
                                await openImmersiveSpace(id: "DIY")
                            }
                        } label: {
                            Text("Choose which planet to move")
                                .font(.title2)
                        }
                    }
                    VStack {
                        Image("Mars")
                            .resizable()
                            .frame(width: 350, height: 175)
                            .cornerRadius(20)
                            .padding()
                        Button {
                            openWindow(id: "Before")
                        } label: {
                            Text("Travel journey to mars")
                                .font(.title2)
                        }
                    }
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
