//
//  SetModeKey.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 28/12/24.
//

import SwiftUI

struct SetModeKey: EnvironmentKey {
    typealias Value = (AstralWildsApp.Mode) async -> Void
    static let defaultValue: Value = { _ in }
}

extension EnvironmentValues {
    var setMode: SetModeKey.Value {
        get { self[SetModeKey.self] }
        set { self[SetModeKey.self] = newValue }
    }
}
