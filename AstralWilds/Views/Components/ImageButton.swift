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
    let chosenMode: AstralWildsApp.Mode
    
    var body: some View {
        VStack {
            Image(name)
                .resizable()
                .frame(width: 300, height: 175)
                .cornerRadius(20)
                .padding()
            Button {
                Task { await setMode(chosenMode) }
            } label: {
                Text(title)
                    .font(.title3)
                    .frame(width: 260, height: 60)
            }
            
        }
    }
}


#Preview(windowStyle: .automatic) {
    ContentView()
}
