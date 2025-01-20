//
//  ImageButton.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 25/10/24.
//

import SwiftUI

/// Reusable button component to open the immersive spaces
struct ImageButton: View {
    
    @Environment(\.setMode) private var setMode
    
    let name: String
    let title: String
    let chosenMode: AstralWildsApp.Mode
    
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            
            let maxSpacing: CGFloat = 20
            let minSpacing: CGFloat = 5
            let dynamicSpacing = max(minSpacing, min(maxSpacing, size.width * 0.025))
            
            let imageWidth = size.width * 0.9 + dynamicSpacing
            let imageHeight = size.height * 0.5 + dynamicSpacing
            let textSize = size.height * 0.045
            
            let buttonWidth = size.width
                        
            VStack(spacing: 5) {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(20)
                    .frame(width: imageWidth, height: imageHeight)
                Button {
                    Task { await setMode(chosenMode) }
                } label: {
                    Text(title)
                        .font(.system(size: textSize))
                        .padding()
                        .fontWeight(.bold)
                }
                
            }
            .frame(width: buttonWidth)
        }
    }
}


#Preview(windowStyle: .automatic) {
    MainView()
}
