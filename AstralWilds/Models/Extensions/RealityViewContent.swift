//
//  RealityViewContent.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 21/01/25.
//

import SwiftUI
import RealityKit

/// Since we use a copy of the reality view, it needs to be sendable.
/// The reason this is unchecked is because I cannot put this into the core definition of RealityViewContent, to be precise in the same file it is defined.
extension RealityViewContent: @retroactive @unchecked Sendable {}
