//
//  simd_float4x4.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 12/05/25.
//

import Foundation
import simd

/// Extends the HandSkeleton class to return computed functions for simpler usage.
extension simd_float4x4 {
    
    /// Returns the position component of a 4x4 transform matrix.
    var position: SIMD3<Float> { columns.3.xyz }
    
    /// Transforms a local joint position into world space using the current matrix as the origin.
    ///
    /// Commonly used to convert a joint's local transform into a world-space position using the hand anchor's transform.
    ///
    /// - Parameter localTransform: The local transform of a hand joint relative to its anchor.
    /// - Returns: A `SIMD3<Float>` representing the hand joint's position in world space.
    func worldPosition(from localTransform: simd_float4x4) -> SIMD3<Float> {
        return matrix_multiply(self, localTransform).position
    }
    
    /// Computes the distance between a local-space point and another hand joint,
    /// by applying this matrix to bring that joint into the same local space.
    ///
    /// - Parameters:
    ///   - lhs: A 3D point already in *this* matrix’s local coordinate space.
    ///   - rhs: A 4×4 joint transform (e.g. `middleTipTransform`) in its own local space.
    /// - Returns: The Euclidean distance between `lhs` and the joint position once the joint
    ///   has been transformed into *this* matrix’s coordinate frame.
    func distance(from lhs: SIMD3<Float>, toJoint rhs: simd_float4x4) -> Float {
        let jointInThisSpace = (self * rhs).position
        return simd_distance(lhs, jointInThisSpace)
    }
}
