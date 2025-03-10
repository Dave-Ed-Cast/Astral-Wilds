//
//  WelcomeView.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 23/01/25.
//

import SwiftUI

struct WelcomeView: View {
    
    @Environment(\.setMode) private var setMode
    @State private var scale: CGFloat = 1.0
    
    let gestures = Text("custom gestures").fontWeight(.bold)
    
    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 50) {
                Text("Welcome to Astral Wilds!")
                    .font(.system(size: 40 * scale, weight: .bold))
                
                VStack(spacing: 5) {
                    Text("Explore our solar system differently!")
                    Text("With the use of \(gestures)")
                    Text("you will be able to feel our solar system")
                    Text("in a way you have never experienced!")
                }
                .font(.system(size: 24 * scale))
                .multilineTextAlignment(.center)
                
                Button {
                    Task { await setMode(.mainScreen) }
                } label: {
                    Text("Start")
                        .font(.system(size: 20 * scale, weight: .bold))
                        .padding()
                }
                .padding(20)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                scale = calculateScale(for: geometry.size)
            }
            .onChange(of: geometry.size) { _, newSize in
                scale = calculateScale(for: newSize)
            }
        }
        .background(.black.opacity(0.4))
        .frame(
            minWidth: 520, maxWidth: 1000,
            minHeight: 450, maxHeight: 930
        )
    }
}
