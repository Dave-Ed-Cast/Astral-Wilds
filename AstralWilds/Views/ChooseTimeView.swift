//
//  BeforeImmersiveView.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 17/05/24.
//

import SwiftUI

/// This is the window that lets the user select how long should the immersive travel be.
struct ChooseTimeView: View {
    
    @Binding var durationSelection: Int
    @Binding var sitting: Bool
    
    @Environment(\.setMode) private var setMode
    @Environment(\.dismissWindow) private var dismissWindow
    
    var body: some View {
        
        VStack(spacing: 35) {
            
            Text("Select the parameters.")
                .font(.title2)
            
            VStack {
                Text("It is recommended to bring snacks and sit comfortably.")
                Text("Then, position this window where you want the journey to happen.")
            }
            .font(.callout)
            
            VStack(spacing: 5) {
                Picker("Choose:", selection: $durationSelection) {
                    Text("1 minute").tag(0)
                    Text("3 minutes").tag(1)
                }
                
                Text("Are you sitting?").font(.title3)
                    .padding()
                Picker("Are you sitting?:", selection: $sitting) {
                    Text("Yes").tag(true)
                    Text("No").tag(false)
                }
            }
            .frame(width: 400)
            .pickerStyle(.palette)
            
            Button {
                Task { await setMode(.immersiveTravel) }
            } label: {
                Text("Launch immersive view")
            }
            
        }
//        .overlay(alignment: .topLeading) {
//            Button {
//                Task { await setMode(.mainScreen) }
//                dismissWindow(id: "TimeWindow")
//            } label: {
//                Image(systemName: "chevron.left")
//            }
//            .buttonStyle(.borderless)
//        }
        .multilineTextAlignment(.center)
        .padding()
        
    }
}

#Preview(windowStyle: .automatic) {
    ChooseTimeView(durationSelection: .constant(0), sitting: .constant(true))
}

