//
//  AudioPlayer.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 21/12/24.
//

import Foundation

/// Used to return a scalar in SIMD3 format
extension SIMD4 {
    var xyz: SIMD3<Scalar> {
        self[SIMD3(0, 1, 2)]
    }
}

