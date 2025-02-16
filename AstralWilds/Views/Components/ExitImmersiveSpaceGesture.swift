//
//  ExitImmersiveSpace.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 13/11/24.
//

import SwiftUI

/// Window telling the user how to exit immersive space through gesture
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
            .font(.body)
            Image("Snap")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .colorInvert()
        }
        .padding()
    }
}
