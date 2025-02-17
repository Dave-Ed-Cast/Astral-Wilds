//
//  TutorialView.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 26/01/25.
//

import SwiftUI
import RealityKit

struct TutorialView: View {
        
    let boldSnap = Text("snap").fontWeight(.bold)
    
    var body: some View {
        
        HStack(alignment: .center) {
            VStack(alignment: .center) {
                Text("Immersive spaces can be overwhelming.")
                Text("So, if windows are closed, \(boldSnap) your fingers.")
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

#Preview(windowStyle: .automatic) {
    TutorialView()
}
