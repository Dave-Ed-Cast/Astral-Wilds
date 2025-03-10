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
            Text("\(boldSnap) your fingers to go back.")
                .multilineTextAlignment(.center)
                .font(.body)
            Image("Snap")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .colorInvert()
        }
        .frame(width: 220, height: 100)
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    TutorialView()
}
