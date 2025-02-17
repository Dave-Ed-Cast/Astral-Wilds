//
//  ExitImmersiveSpace.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 13/11/24.
//

import SwiftUI

/// Window telling the user how to exit immersive space through gesture (only with device)
struct ExitImmersiveSpaceGesture: View {
    
    @Environment(\.setMode) private var setMode
        
    let boldSnap = Text("snap").fontWeight(.bold)
    
    var body: some View {
        
        HStack(alignment: .center) {
            VStack(alignment: .center) {
                Text("Immersive spaces can be overwhelming.")
                Text("Therefore, \(boldSnap) your fingers to go back.")
            }
            .multilineTextAlignment(.center)
            .font(.caption)
            Image("Snap")
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .colorInvert()
        }
        .padding()
    }
}
