//
//  ExitImmersiveSpace.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 13/11/24.
//

import SwiftUI

/// Reusable button that handles the exiting of the immersive spaces
struct ExitImmersiveSpace: View {
    
    @Environment(\.setMode) private var setMode
    
    @Binding var mode: AstralWildsApp.Mode
    
    var body: some View {
        VStack(spacing: 10) {
            let snapText = Text("snap").fontWeight(.bold)
            VStack {
                Text("Feeling overwhelmed?").font(.title)
                Text("Click the button or \(snapText) your fingers.")
            }
            
            if mode == .immersiveTravel {
                VStack {
                    Text("Spatial audio is playing.")
                    Text("Consider repositioning this window.")
                }
            } else if mode == .choosePlanetsToMove {
                Text("Tap on a planet to move it or stop it")
            }
            
            Button {
                Task { await setMode(.mainScreen) }
            } label: {
                Text("Back").font(.headline)
            }
        }
        .font(.subheadline)
        .multilineTextAlignment(.center)
        .padding()
    }
}
