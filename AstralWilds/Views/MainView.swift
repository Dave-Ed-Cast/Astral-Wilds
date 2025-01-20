//
//  ContentView.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

import SwiftUI

/// View that handles all the main flow of the app
struct MainView: View {
    
    @Environment(\.setMode) private var setMode
        
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            let titleTextSize = size.height * 0.07
            let titleTextPadding = size.height * 0.1
            let headlineTextSize = size.height * 0.04
            let adaptivePadding = size.width * 0.02
            
            let maxSpacing: CGFloat = 10
            let minSpacing: CGFloat = 5
            let dynamicSpacing = max(minSpacing, min(maxSpacing, size.width * 0.085))
            
            VStack(spacing: dynamicSpacing) {
                Text("Welcome to Astral Wilds!")
                    .font(.system(size: titleTextSize))
                    .padding(titleTextPadding)
                
                VStack(alignment: .leading, spacing: dynamicSpacing * 0.3) {
                    HStack {
                        Text("Choose what to explore!")
                            .font(.system(size: headlineTextSize))
                    }
                    .padding(.leading, adaptivePadding)
                    
                    HStack(spacing: 10) {
                        ImageButton(name: "SolarSystem", title: "Solar system", chosenMode: .movingPlanets)
                        ImageButton(name: "Touch", title: "Preferred planets", chosenMode: .choosePlanetsToMove)
                        ImageButton(name: "Mars", title: "Mars Travel", chosenMode: .chooseTime)
                    }
                    
//                    VStack(spacing: 10) {
//                        NewImageButton(name: "SolarSystem", text: text1, chosenMode: .movingPlanets)
//                        NewImageButton(name: "Touch", text: text1, chosenMode: .choosePlanetsToMove)
//                        NewImageButton(name: "Mars", text: text1, chosenMode: .chooseTime)
//                    }
                    .environment(\.setMode, setMode)
                }
            }
            .onChange(of: size) {
                print("width: \(size.width), height: \(size.height)")
            }
            .padding()
            .fontWeight(.bold)

        }
    }
    
            
}

#Preview(windowStyle: .automatic) {
    MainView()
}
