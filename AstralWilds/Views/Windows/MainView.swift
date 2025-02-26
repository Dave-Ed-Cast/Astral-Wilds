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
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @State private var showTutorial: Bool = false
    var body: some View {
        
        VStack(spacing: 20) {
            
            Text("Choose what to explore!")
                .font(.largeTitle)
            VStack(alignment: .leading, spacing: 10) {
                
                ImageButton(
                    name: "SolarSystem",
                    text: "Put yourself at the center of the univers and admire, from up close, how the solar system works!",
                    chosenMode: .movingPlanets
                )
                ImageButton(
                    name: "Touch",
                    text: "In this playground, interact with each planet and make it your toy!",
                    chosenMode: .choosePlanetsToMove
                )
                ImageButton(
                    name: "Mars",
                    text: "Experience a simulated travel to Mars, while admiring the red planet!",
                    chosenMode: .chooseTime
                )
            }
            .environment(\.setMode, setMode)
        }
        .overlay(alignment: .topTrailing) {
            Button {
                showTutorial = true
            } label: {
                Image(systemName: "info.circle")
                   
            }
            .popover(isPresented: $showTutorial, attachmentAnchor: .point(.init(x: 4, y: 0)) ) {
                TutorialView()
                    .frame(width: 350, height: 200)
                    .background(.black.opacity(0.4)).ignoresSafeArea(.all)
                    .fixedSize()
            }
            
            .buttonStyle(.borderless)
            .padding()
        }
        
        .padding()
        .fontWeight(.bold)
        
        /// For whatever reason, the tested code that should close the window doesn't close it.
        /// The dismissWindow in the setMode function doesn't work properly
        .onAppear {
            dismissWindow(id: "Welcome")
        }
    }
}

#Preview(windowStyle: .automatic) {
    MainView()
}
