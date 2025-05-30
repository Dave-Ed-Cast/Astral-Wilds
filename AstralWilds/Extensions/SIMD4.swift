//
//  AudioPlayer.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 21/12/24.
//

import Foundation

extension SIMD4 {
    
    /// Used to return a coordinates in SIMD3 format.
    /// Specifically used for world coordinates.
    var xyz: SIMD3<Scalar> {
        self[SIMD3(0, 1, 2)]
    }
}

