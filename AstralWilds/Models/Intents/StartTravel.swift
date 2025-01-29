//
//  AppIntents.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 28/01/25.
//


import Foundation
import AppIntents

struct StartTravel: AppIntent {
    static let title: LocalizedStringResource = "Start Meditation"
    
    static let description = IntentDescription(
        "Start a meditation session in the app.",
        categoryName: "Health & Wellness"
    )
    
    @Parameter(title: "Session Name", default: "Relaxation")
    var sessionName: String
    
    @MainActor func perform() async throws -> some IntentResult {
        // Trigger your app's functionality here
        print("Starting session: \(sessionName)")
        return .result(dialog: "Starting your \(sessionName) session.")
    }
}
