//
//  ExitImmersiveSpace.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 13/11/24.
//

import SwiftUI

/// Reusable button that handles the exiting of the immersive spaces (only simulator)
struct ExitImmersiveSpaceButton: View {
    
    @Environment(\.setMode) private var setMode
    @Environment(\.pushWindow) private var pushWindow
    
    @Binding var mode: AstralWildsApp.Mode
    
    var body: some View {
        VStack(spacing: 10) {
            let snapText = Text("snap").fontWeight(.bold)
            VStack {
                Text("Feeling overwhelmed?").font(.title3)
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
        .onAppear { pushWindow(id: ModeIDs.buttonWindowID) }
        .font(.subheadline)
        .multilineTextAlignment(.center)
        .frame(width: 350, height: 180)
        .standardModifiers()
    }
}
