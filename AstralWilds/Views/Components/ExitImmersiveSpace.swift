//
//  ExitImmersiveSpace.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 13/11/24.
//

import SwiftUI
import RealityKitContent

/// Reusable button that handles the exiting of the immersive spaces
struct ExitImmersiveSpace: View {
    
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.setMode) private var setMode
    
    @Binding var mode: AstralWildsApp.Mode
    
    fileprivate let buttonWindowID: String = "Button"
    
    var body: some View {
        VStack(spacing: 30) {
            let snapText = Text("snap").fontWeight(.bold)
            VStack {
                Text("Feeling overwhelmed?").font(.title)
                Text("Click the button or \(snapText) your fingers.").font(.subheadline)
            }
            .multilineTextAlignment(.center)
            
            if mode == .immersiveSpace {
                VStack {
                    Text("Spatial audio is playing.")
                    Text("Consider repositioning this window.")
                }
                .font(.callout)
                .multilineTextAlignment(.center)
                
            } else if mode == .choosePlanetsToMove {
                Text("Tap on a planet to move it or stop it")
                    .font(.callout)
                    .multilineTextAlignment(.center)
            }
            
            Button {
                Task { await setMode(.mainScreen) }
                
                //the button window needs to go when the immersive space disappears
                dismissWindow(id: buttonWindowID)
                
            } label: {
                Text("Back")
                    .font(.headline)
            }
        }
        .multilineTextAlignment(.center)
        .padding()
    }
}
