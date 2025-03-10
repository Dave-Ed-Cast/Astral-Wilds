//
//  ImageButton.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 25/10/24.
//

import SwiftUI

/// Reusable button component to open the immersive spaces
/// This optimizees the operation of opening the next `chosenMode`
/// Refer to the `setMode` function 
struct ImageButton: View {
    
    @Environment(\.setMode) private var setMode
    
    @State private var scale: CGFloat = 1.0
    
    let name: String
    let text: String
    let chosenMode: AstralWildsApp.Mode
    
    var body: some View {
        GeometryReader { geometry in
            Button {
                Task { await setMode(chosenMode) }
            } label: {
                HStack(alignment: .center, spacing: 30) {
                    Image(name)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(20)
                        .frame(width: 200, height: 100)
                    Text(text)
                        .font(.headline)
                }
            }
            .background(.clear)
            .buttonStyle(.borderless)
        }
        .hoverEffect(.lift)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}

#Preview(windowStyle: .automatic) {
    MainView()
}

