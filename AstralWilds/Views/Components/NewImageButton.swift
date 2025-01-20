//
//  ImageButton.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 25/10/24.
//

import SwiftUI

/// Reusable button component to open the immersive spaces
struct NewImageButton: View {
    
    @Environment(\.setMode) private var setMode
    
    let name: String
    let text: String
    let chosenMode: AstralWildsApp.Mode
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            let maxSpacing: CGFloat = 20
            let minSpacing: CGFloat = 5
            let dynamicSpacing = max(minSpacing, min(maxSpacing, size.width * 0.025))
            
            let imageWidth = size.width * 0.9 + dynamicSpacing
            let imageHeight = size.height * 0.5 + dynamicSpacing
            let textSize = size.height * 0.16
            
            let buttonWidth = size.width * 0.035
            let buttonHeight = size.height * 0.05
            
            HStack(spacing: 10) {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(20)
                    .padding(dynamicSpacing)
                    
                Text(text)
                    .font(.system(size: textSize)).fontWeight(.bold)
                    .overlay(alignment: .bottomTrailing) {
                        Button {
                            Task { await setMode(chosenMode) }
                        } label: {
                            Image(systemName: "play.circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: buttonWidth, height: buttonHeight)
                        }
                    }
            }
            
        }
    }
}


#Preview(windowStyle: .automatic) {
    MainView()
}

