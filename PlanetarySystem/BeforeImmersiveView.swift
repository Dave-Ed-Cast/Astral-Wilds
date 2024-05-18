//
//  BeforeImmersiveView.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 17/05/24.
//

import SwiftUI

struct BeforeImmersiveView: View {
    
    @State var durationSelection: Int = 60
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.openImmersiveSpace) var openImmersiveSpace

    var body: some View {
        
        VStack {
            Text("Welcome, please sit back and relax.")
            Text("Before moving on, please select the duration of your journey.")
            
            Picker("Choose: ", selection: $durationSelection) {
                Text("1 minute")
                    .tag(60)
                Text("3 minutes")
                    .tag(180)
            }
            .pickerStyle(.inline)
            
            Button {
                Task {
                    await openImmersiveSpace(id: "ImmersiveView")
                }
            } label: {
                Text("Launch immersive view")
            }
            
        }
        .onAppear {
            dismissWindow(id: "main")
        }
    }
}

#Preview {
    BeforeImmersiveView()
}
