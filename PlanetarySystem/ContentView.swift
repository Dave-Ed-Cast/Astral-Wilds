//
//  ContentView.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    var body: some View {
        NavigationSplitView {
            List {
                Text("Item")
            }
            .navigationTitle("Sidebar")
        } detail: {
            VStack {
                Text("Hello, world!")
                Button {
                    Task {
                        await openImmersiveSpace(id: "saturn")
                    }
                } label: {
                    Text("Open saturn")
                }
            }
            .padding()
            .navigationTitle("Content")
        }
        
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
