//
//  SetModeKey.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 28/12/24.
//

import SwiftUI

/// This SetModeKey allows to create a new `Environment` key. The default value
/// can be `nonisolated(unsafe)` because it's an empty closure perfoming no operations
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
