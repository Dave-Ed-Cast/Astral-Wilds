//
//  ContentView.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    @Environment(\.setMode) var setMode
        
    var body: some View {
        VStack(spacing: 80) {
            VStack(spacing: 10) {
                Text("Welcome!")
                    .font(.extraLargeTitle)
                Text("Choose what do you want to explore")
                    .font(.title2)
            }
            HStack {
                ImageButton(name: "SolarSystem", title: "View the solar system", chosenMode: .planets)
                ImageButton(name: "Touch", title: "Move your preferred planets", chosenMode: .choosePlanetsToMove)
                ImageButton(name: "Mars", title: "Travel to mars", chosenMode: .chooseTime)
            }
            .environment(\.setMode, setMode)
        }
        
        .padding()
        .navigationBarTitleDisplayMode(.automatic)
    }
}


#Preview(windowStyle: .automatic) {
    ContentView()
}
