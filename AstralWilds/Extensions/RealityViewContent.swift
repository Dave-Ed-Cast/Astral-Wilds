//
//  RealityViewContent.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 21/01/25.
//

import SwiftUI
import RealityKit

/// This makes the compiler shut up but for the purpose of the app,
/// this is fine to do. We are only gonna load scenes and detect gestures
/// meaning that everything will be concurrency safe whatsoever.
extension RealityViewContent: @retroactive @unchecked Sendable {}
