//
//  HandTrackingSystem.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 09/05/25.
//

import RealityKit
import ARKit

/// A system that updates entities that have hand-tracking components, now visualizing each joint with a 3D axis.
struct HandTrackingSystem: System {
    
    static let arSession = ARKitSession()
    static let handTracking = HandTrackingProvider()
    @MainActor static var latestLeftHand: HandAnchor?
    @MainActor static var latestRightHand: HandAnchor?
    
    @MainActor private static let gestureRecognizer = GestureRecognizer.shared
    
    init(scene: RealityKit.Scene) {
        Task { await Self.runSession() }
    }
    
    @MainActor
    static func runSession() async {
        do {
            try await arSession.run([handTracking])
        } catch let error as ARKitSession.Error {
            print("Error running providers: \(error.localizedDescription)")
        } catch let error {
            print("Unexpected error: \(error.localizedDescription)")
        }
        
        for await update in handTracking.anchorUpdates {
            switch update.anchor.chirality {
            case .left: latestLeftHand = update.anchor
            case .right: latestRightHand = update.anchor
            }
        }
    }
    
    static let query = EntityQuery(where: .has(HandTrackingComponent.self))
    
    func update(context: SceneUpdateContext) {
        let hands = context.entities(matching: Self.query, updatingSystemWhen: .rendering)
        
        for entity in hands {
            guard let handComp = entity.components[HandTrackingComponent.self] else { continue }
            guard let anchor = (handComp.chirality == .left ? Self.latestLeftHand : Self.latestRightHand),
                  let skeleton = anchor.handSkeleton else { continue }
            
            for (jointName, jointEntity) in handComp.fingers {
                let jointTransform = skeleton.joint(jointName).anchorFromJointTransform
                jointEntity.setTransformMatrix(
                    anchor.originFromAnchorTransform * jointTransform,
                    relativeTo: nil
                )
            }
            
            let left = Self.latestLeftHand
            let right = Self.latestRightHand
            
            Self.gestureRecognizer.thanosSnap(left: left, right: right)
            
        }
    }
}
