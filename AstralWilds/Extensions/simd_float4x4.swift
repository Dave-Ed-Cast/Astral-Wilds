//
//  simd_4x4.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 29/05/25.
//

import ARKit

extension simd_float4x4 {
    
    /// Returns the position component of a 4x4 transform matrix.
    var position: SIMD3<Float> { columns.3.xyz }
}
