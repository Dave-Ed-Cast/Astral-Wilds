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
    
    @Environment(\.setMode) var setMode
    
    @State private var immersiveSpaceID: String? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome!")
                .font(.extraLargeTitle)
            Text("Choose what do you want to explore")
                .font(.title2)
                .padding(.bottom, 100)
            HStack {
                ImageButton(name: "SolarSystem", title: "View the solar system", chosenMode: .planets)
                ImageButton(name: "Touch", title: "Choose which planet to move", chosenMode: .choosePlanetsToMove)
                ImageButton(name: "Mars", title: "Travel journey to mars", chosenMode: .chooseTime)
            }
            .environment(\.setMode, setMode)
        }
        .padding()
        .navigationBarTitleDisplayMode(.automatic)
        
        
//        RealityView { content in
//            let mesh = MeshResource.generateText(
//                "Ciao belli",
//                extrusionDepth: 0.5,
//                font: .systemFont(ofSize: 50),
//                containerFrame: .zero,
//                alignment: .center,
//                lineBreakMode: .byWordWrapping
//            )
//
//            let material = SimpleMaterial(color: .red, isMetallic: true)
//            let textEntity = ModelEntity(mesh: mesh, materials: [material])
//            textEntity.position = [0, 0, -1]
//
//            let anchorEntity = AnchorEntity(plane: .horizontal)
//            anchorEntity.name = "anchor"
//            anchorEntity.addChild(textEntity)
//            content.add(anchorEntity)
//            anchorEntity.generateCollisionShapes(recursive: true)
//
//        }
    }
}


#Preview(windowStyle: .automatic) {
    ContentView()
}
