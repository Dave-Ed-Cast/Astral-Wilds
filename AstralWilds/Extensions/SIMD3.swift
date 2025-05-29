//
//  SIMD3.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 12/05/25.
//

import Foundation
import simd

enum Axis {
    case x, y, z
}

/// An extension of `SIMD3<Float>` providing geometric utilities for 3D vector operations.
///
/// These methods are particularly useful for spatial reasoning in hand tracking applications,
/// such as measuring angles between joints or determining gesture directionality in a 3D space.
///
/// The functions assume right-handed coordinate system conventions, as typically used in ARKit and visionOS.
extension SIMD3 where Scalar == Float {
    
    /// Calculates the angle between two 3D vectors in **degrees**.
    ///
    /// Useful for determining angular relationships between joints or bones, such as the flexion
    /// of a finger or the divergence between finger directions.
    ///
    /// - Parameter other: The vector to compute the angle to.
    /// - Returns: The angle between `self` and `other` in degrees, ranging from 0° to 180°.
    func angle(to other: SIMD3<Float>) -> Float {
        let dot = simd_dot(self, other)
        let magnitude = simd_length(self) * simd_length(other)
        let angleRad = acos(simd_clamp(dot / magnitude, -1, 1))
        return angleRad * 180 / .pi
    }
    
    func angle(along axis: Axis, to other: SIMD3<Float>, maxRange: Float = 0.05) -> Float {
        let delta: Float
        
        switch axis {
        case .x: delta = abs(self.x - other.x)
        case .y: delta = abs(self.y - other.y)
        case .z: delta = abs(self.z - other.z)
        }
        
        let normalized = Swift.min(delta / maxRange, 1.0)
        return normalized * 180.0
        
    }
    
    /// Computes the absolute horizontal angle between two points projected onto the **XY plane**.
    ///
    /// Ideal for estimating lateral hand movement or finger pointing direction relative to the X-axis,
    /// when vertical (Z-axis) variation is not relevant or should be ignored.
    ///
    /// - Parameter other: The target point in 3D space to measure the direction to.
    /// - Returns: The **absolute** angle in degrees, ranging from 0° to 180°, between the projected direction and the X-axis.
    func horizontalAngle(to other: SIMD3<Float>) -> Float {
        let vec = self - other
        return abs(atan2(vec.y, vec.x) * 180 / .pi)
    }
}
