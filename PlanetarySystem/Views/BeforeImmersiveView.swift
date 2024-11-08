//
//  BeforeImmersiveView.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 17/05/24.
//

import SwiftUI

/// This is the window that lets the user select how long should the immersive travel be.
///
/// Note that there is a dismiss window because it is not properly handled in the setMode function
struct BeforeImmersiveView: View {
    
    @Binding var durationSelection: Int
    @Environment(\.setMode) private var setMode
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        
        VStack(spacing: 50) {
            
            Text("Please select the duration of your journey.")
                .font(.title2)
            
            VStack {
                Text("It is advised to be in a quiet and calm environment for this duration.")
                Text("Furthermore, before starting please bring the window closer to you.")
            }
            .font(.callout)

            Picker("Choose: ", selection: $durationSelection) {
                Text("1 minute").tag(0)
                Text("3 minutes").tag(1)
            }
            .frame(width: 400)
            .pickerStyle(.palette)
            
            Button {
                Task { await setMode(.immersiveSpace) }
            } label: {
                Text("Launch immersive view")
            }
            
        }
        .padding()
        .onAppear {
            dismissWindow(id: "main")
        }
    }
}
