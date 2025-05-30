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
    @Environment(\.pushWindow) private var pushWindow
        
    let boldSnap = Text("snap").fontWeight(.bold)
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 15) {
            VStack(alignment: .center) {
                Text("If you want to go back")
                Text("\(boldSnap) your fingers.")
            }
            .multilineTextAlignment(.center)
            .font(.headline)
            Image("Snap")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .colorInvert()
        }
        .padding()
        .frame(width: 350, height: 180)
        .background(.black.opacity(0.4))
        .fixedSize()
        .onAppear { pushWindow(id: ModeIDs.buttonWindowID) }
    }
}
