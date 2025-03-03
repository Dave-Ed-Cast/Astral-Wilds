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
        }
        .overlay(alignment: .topTrailing) {
            Button {
                withAnimation {
                    showTutorial = true
                }
            } label: {
                Image(systemName: "info.circle")
            }
            .popover(isPresented: $showTutorial, attachmentAnchor: .point(.init(x: -3, y: 1.5)) ) {
                TutorialView()
                    .frame(width: 360, height: 200)
                    .background(.black.opacity(0.4)).ignoresSafeArea(.all)
                    .fixedSize()
            }
            
            .buttonStyle(.borderless)
            .padding()
        }
        .opacity(showTutorial ? 0.65 : 1)
        .padding()
        .fontWeight(.bold)
    }
}

#Preview(windowStyle: .automatic) {
    MainView()
        .frame(
            minWidth: 700, maxWidth: 1000,
            minHeight: 550, maxHeight: 900
        )
}
