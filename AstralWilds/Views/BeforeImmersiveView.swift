//
//  BeforeImmersiveView.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 17/05/24.
//

import SwiftUI

/// This is the window that lets the user select how long should the immersive travel be.
struct BeforeImmersiveView: View {
    
    @Binding var durationSelection: Int
    @Environment(\.setMode) private var setMode
    @Environment(\.dismissWindow) private var dismissWindow
    
    private let mainScreen = AstralWildsApp.Mode.mainScreen.windowId

    var body: some View {
        
        VStack(spacing: 35) {
            
            Text("Select the duration of your journey.")
                .font(.title2)
            
            VStack {
                Text("It is recommended to bring some snacks and sit comfortably.")
                Text("Then, position this window where you want the journey to happen.")
            }
            .font(.callout)

            Picker("Choose:", selection: $durationSelection) {
                Text("1 minute").tag(0)
                Text("3 minutes").tag(1)
            }
            .frame(width: 400)
            .pickerStyle(.palette)
            
            Button {
                Task { await setMode(.immersiveTravel) }
            } label: {
                Text("Launch immersive view")
            }
            
        }
        .multilineTextAlignment(.center)
        .padding()
        
        /// Despite having `setMode`, manually dismissing the window is better, as the function handles things modularly.
        /// Checking for an overlay each time across all routes is more resource-intensive.
        .onAppear {
            dismissWindow(id: mainScreen)
        }
    }
}

#Preview(windowStyle: .automatic) {
    BeforeImmersiveView(durationSelection: .constant(0))
}

