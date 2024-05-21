//
//  PlanetarySystemApp.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

import SwiftUI

@main
struct PlanetarySystemApp: App {
    
    // this are the variables needed for the immersive space
    @State var immersionMode: ImmersionStyle = .full
    @State private var selectedDuration: Int = 60
    
    var body: some Scene {
        //MARK: we define the views to call and dismiss on command with id
        
        WindowGroup(id: "main"){
            ContentView()
        }
        
        WindowGroup(id: "Before") {
            BeforeImmersiveView()
        }
        
        //same thing here
        ImmersiveSpace(id: "planets") {
            Planets()
        }
        .immersionStyle(selection: $immersionMode, in: .full)
        
        ImmersiveSpace(id: "DIY") {
            PlanetsDIY()
        }
        .immersionStyle(selection: $immersionMode, in: .full)
        
        
        ImmersiveSpace(id: "ImmersiveView") {
            ImmersiveView(duration: $selectedDuration)
        }
        .immersionStyle(selection: $immersionMode, in: .full)
    }
}
