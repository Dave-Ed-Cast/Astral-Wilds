//
//  AppIntents.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 28/01/25.
//


import AppIntents

struct AppShortcutProvider: AppShortcutsProvider {

    static var appShortcuts: [AppShortcut] {
        
        AppShortcut(
            intent: StartTravel(),
            phrases: [
                "Travel to Mars",
                "Start a new adventure",
                "Start travel",
                "Start a travel session"
            ],
            shortTitle: "Travel",
            systemImageName: "info.circle"
        )
        
    }
}
