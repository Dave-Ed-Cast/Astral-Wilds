//
//  TutorialView.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 26/01/25.
//

import SwiftUI
import RealityKit

struct TutorialView: View {
    
    @Environment(\.dismissWindow) private var dismissWindow
    
    let boldSnap = Text("snap").fontWeight(.bold)
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            
            HStack(alignment: .center) {
                VStack(alignment: .center) {
                    Text("Immersive spaces might be overwhelming.")
                    Text("So, if windows are closed, \(boldSnap) your fingers.")
                }
                .font(.body)
                Image("Snap")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .colorInvert()
            }
            .padding()
            Button {
                dismissWindow(id: "Tutorial")
            } label: {
                Text("Close")
            }
        }
        .padding(25)
    }
}

#Preview {
    TutorialView()
}
