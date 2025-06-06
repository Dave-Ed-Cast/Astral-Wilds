//
//  TutorialView.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 26/01/25.
//

import SwiftUI

struct TutorialView: View {
    
    let boldSnap = Text("snap").fontWeight(.bold)
    
    var body: some View {
        
        HStack(alignment: .center) {
            Text("During immersion, \(boldSnap) your fingers to go back.")
            
                .multilineTextAlignment(.center)
                .font(.body)
            Image("Snap")
                .resizable()
                .scaledToFit()
                .frame(width: 64, height: 64)
                .colorInvert()
        }
        .frame(width: 300, height: 150)
        .standardModifiers()
    }
}

#Preview(windowStyle: .automatic) {
    TutorialView()
}
