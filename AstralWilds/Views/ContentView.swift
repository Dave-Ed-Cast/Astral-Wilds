//
//  ContentView.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

/// View that handles all the main flow of the app
struct ContentView: View {
    
    @Environment(\.setMode) private var setMode
        
    var body: some View {
        VStack(spacing: 100) {
            Text("Welcome to Astral Wilds!")
                .font(.extraLargeTitle)
            
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Choose what to explore!")
                        .font(.title2)
                }
                .padding(.leading, 15)
                HStack(spacing: 10) {
                    ImageButton(name: "SolarSystem", title: "View the solar system", chosenMode: .planets)
                    ImageButton(name: "Touch", title: "Move preferred planets", chosenMode: .choosePlanetsToMove)
                    ImageButton(name: "Mars", title: "Travel to Mars", chosenMode: .chooseTime)
                }
                .environment(\.setMode, setMode)
            }
        }
    }
    
            
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
