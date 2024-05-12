//
//  PlanetarySystemApp.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

import SwiftUI

@main
struct PlanetarySystemApp: App {
    var body: some Scene {
        WindowGroup(id: "main"){
            ContentView()
        }
        
        ImmersiveSpace(id: "saturn") {
            Planets()
        }
    }
}
