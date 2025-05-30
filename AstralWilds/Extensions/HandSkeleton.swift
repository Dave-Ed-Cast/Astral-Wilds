//
//  HandSkeleton.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 13/05/25.
//

import ARKit

/// Extends the HandSkeleton class to return computed values for simpler usage.
extension HandSkeleton {
    
    /// Helper function that allows to return the exact transform of that finger bone
    private func transform(of joint: HandSkeleton.JointName) -> simd_float4x4 {
        return self.joint(joint).anchorFromJointTransform
    }
    
    //Wrist, Forearm
    var wristTransform: simd_float4x4 { return transform(of: .wrist) }
    var forearmArmTransform: simd_float4x4 { return transform(of: .forearmArm) }
    var forearmWristTransform: simd_float4x4 { return transform(of: .forearmWrist) }
    
    //Thumb
    var thumbKnuckleTransform: simd_float4x4 { return transform(of: .thumbKnuckle) }
    var thumbIntermediateBaseTransform: simd_float4x4 { return transform(of: .thumbIntermediateBase) }
    var thumbIntermediateTipTransform: simd_float4x4 { return transform(of: .thumbIntermediateTip) }
    var thumbTipTransform: simd_float4x4 { return transform(of: .thumbTip) }
    
    //Index
    var indexFingerMetacarpalTransform: simd_float4x4 { return transform(of: .indexFingerMetacarpal) }
    var indexFingerKnuckleTransform: simd_float4x4 { return transform(of: .indexFingerKnuckle) }
    var indexFingerIntermediateBaseTransform: simd_float4x4 { return transform(of: .indexFingerIntermediateBase) }
    var indexIntermediateTipTransform: simd_float4x4 { return transform(of: .indexFingerIntermediateTip) }
    var indexTipTransform: simd_float4x4 { return transform(of: .indexFingerTip) }
    
    //Middle
    var middleFingerMetacarpalTransform: simd_float4x4 { return transform(of: .middleFingerMetacarpal) }
    var middleFingerKnuckleTransform: simd_float4x4 { return transform(of: .middleFingerKnuckle) }
    var middleFingerIntermediateBaseTransform: simd_float4x4 { return transform(of: .middleFingerIntermediateBase) }
    var middleIntermediateTipTransform: simd_float4x4 { return transform(of: .middleFingerIntermediateTip) }
    var middleTipTransform: simd_float4x4 { return transform(of: .middleFingerTip) }
    
    //Ring
    var ringFingerMetacarpalTransform: simd_float4x4 { return transform(of: .ringFingerMetacarpal) }
    var ringFingerKnuckleTransform: simd_float4x4 { return transform(of: .ringFingerKnuckle) }
    var ringFingerIntermediateBaseTransform: simd_float4x4 { return transform(of: .ringFingerIntermediateBase) }
    var ringIntermediateTipTransform: simd_float4x4 { return transform(of: .ringFingerIntermediateTip) }
    var ringTipTransform: simd_float4x4 { return transform(of: .ringFingerTip) }
    
    //Little (Pinky)
    var littleFingerMetacarpalTransform: simd_float4x4 { return transform(of: .littleFingerMetacarpal) }
    var littleFingerKnuckleTransform: simd_float4x4 { return transform(of: .littleFingerKnuckle) }
    var littleFingerIntermediateBaseTransform: simd_float4x4 { return transform(of: .littleFingerIntermediateBase) }
    var littleIntermediateTipTransform: simd_float4x4 { return transform(of: .littleFingerIntermediateTip) }
    var littleTipTransform: simd_float4x4 { return transform(of: .littleFingerTip) }
    
    
}
