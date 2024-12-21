//
//  ImageButton.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 25/10/24.
//

import SwiftUI
import RealityKitContent

/// Reusable button component to open the immersive spaces
struct ImageButton: View {
    
    @Environment(\.setMode) private var setMode
    let name: String
    let title: String
    let chosenMode: PlanetarySystemApp.Mode
    
    var body: some View {
        VStack {
            Image(name)
                .resizable()
                .frame(width: 320, height: 175)
                .cornerRadius(20)
                .padding()
            Button {
                Task { await setMode(chosenMode) }
            } label: {
                Text(title)
                    .font(.title2)
                    .frame(width: 280, height: 60)
            }
        }
        .padding()
    }
}
