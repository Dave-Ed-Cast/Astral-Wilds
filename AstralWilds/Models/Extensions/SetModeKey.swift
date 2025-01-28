//
//  SetModeKey.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 28/12/24.
//

import SwiftUI

/// This can be nonisolated(unsafe) because it is protected in the `setMode` function.
struct SetModeKey: @preconcurrency EnvironmentKey {
    typealias Value = (AstralWildsApp.Mode) async -> Void
    @MainActor static let defaultValue: Value = { _ in }
}

extension EnvironmentValues {
    var setMode: SetModeKey.Value {
        get { self[SetModeKey.self] }
        set { self[SetModeKey.self] = newValue }
    }
}
