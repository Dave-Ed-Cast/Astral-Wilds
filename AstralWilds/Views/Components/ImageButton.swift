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
                        .frame(width: 200 * scale, height: 100 * scale)
                    Text(text)
                        .font(.system(size: 20 * scale))
                        .frame(maxWidth: 500 * scale)
                        .padding()
                }
                
            }
            .onAppear {
                scale = calculateScale(for: geometry.size)
            }
            .onChange(of: geometry.size) { _, newSize in
                scale = calculateScale(for: newSize)
                print(scale)
            }
            .background(.clear)
            .buttonStyle(.plain)
        }
        
    
        .hoverEffect(.lift).clipShape(.buttonBorder)
        .onTapGesture {
            
        }
        
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
}

#Preview(windowStyle: .automatic) {
    MainView()
}

