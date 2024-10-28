//
//  LeaveImmersiveView.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 28/10/24.
//

import SwiftUI

struct BackToRealityButtonView: View {
    
    @Environment(\.setMode) private var setMode
    
    var body: some View {
        ZStack {
            Button {
                Task { await setMode(.mainScreen) }
            } label: {
                Text("Go back to reality")
            }
        }
        
    }
}

#Preview {
    BackToRealityButtonView()
}
