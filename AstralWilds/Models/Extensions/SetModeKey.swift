//
//  SetModeKey.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 28/12/24.
//

import SwiftUI

/// This can be nonisolated(unsafe) because it is protected in the `setMode` function.
/// The defualt value can be `nonisolated(unsafe)` because it's protected in the
/// `setMode` function through the `MainActor`
struct SetModeKey: EnvironmentKey {
    typealias Value = (AstralWildsApp.Mode) async -> Void
    nonisolated(unsafe) static let defaultValue: Value = { _ in }
}

extension EnvironmentValues {
    var setMode: SetModeKey.Value {
        get { self[SetModeKey.self] }
        set { self[SetModeKey.self] = newValue }
    }
}
