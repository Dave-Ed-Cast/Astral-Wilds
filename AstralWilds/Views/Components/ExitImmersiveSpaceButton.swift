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
    
    let snapText = Text("snap").fontWeight(.bold)
        
    var body: some View {
        VStack(spacing: 15) {
            VStack {
                Text("Feeling overwhelmed?").font(.title3)
                Text("Click the button or \(snapText) your fingers.")
            }
            Button {
                Task { await setMode(.mainScreen) }
            } label: {
                Text("Back").font(.headline)
            }
        }
        .frame(width: 350, height: 180)
        .background(.black.opacity(0.4))
        .fixedSize()
        .font(.subheadline)
        .multilineTextAlignment(.center)
        .padding()
    }
}
