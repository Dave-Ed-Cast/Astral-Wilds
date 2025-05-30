//
//  BeforeImmersiveView.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 17/05/24.
//

import SwiftUI

/// This is the window that lets the user select how long should the immersive travel be.
struct ChooseTimeView: View {
    
    @Binding var durationSelection: Int
    @Binding var sitting: Bool
    
    @Environment(\.setMode) private var setMode
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        
        VStack(spacing: 10) {
            Text("Select the parameters.")
                .font(.title2)
            VStack {
                Text("It is recommended to bring snacks!")
                Text("Then, put the window where you prefer.")
            }
            .font(.callout)
                        
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Duration:")
                        .font(.headline)
                        .padding(.horizontal, 10)
                    Picker("Choose:", selection: $durationSelection) {
                        Text("1 minute").tag(0)
                        Text("3 minutes").tag(1)
                    }
                }
                VStack(alignment: .leading) {
                    Text("Are you sitting?")
                        .font(.headline)
                        .padding(.horizontal, 10)
                    Picker("Are you sitting?:", selection: $sitting) {
                        Text("Yes").tag(true)
                        Text("No").tag(false)
                    }
                }
            }
            .padding()
            .pickerStyle(.palette)
            
            Button("Start Travel") { Task { await setMode(.immersiveTravel) }}
        }
        .frame(width: 350, height: 350)
        .multilineTextAlignment(.center)
        .padding()
        
    }
}

#Preview(windowStyle: .plain) {
    ChooseTimeView(durationSelection: .constant(0), sitting: .constant(true))
        .frame(width: 400)
}

