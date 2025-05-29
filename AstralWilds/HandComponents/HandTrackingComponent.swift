//
//  HandTrackingComponent.swift
//  DomainExpansion
//
//  Created by Davide Castaldi on 09/05/25.
//

import RealityKit
import ARKit.hand_skeleton

/// A component that tracks the hand skeleton.
struct HandTrackingComponent: Component {
    /// The chirality for the hand this component tracks.
    let chirality: AnchoringComponent.Target.Chirality

    /// A lookup that maps each joint name to the entity that represents it.
    var fingers: [HandSkeleton.JointName: Entity] = [:]
    
    /// Creates a new hand-tracking component.
    /// - Parameter chirality: The chirality of the hand target.
    @MainActor init(chirality: AnchoringComponent.Target.Chirality) {
        self.chirality = chirality
        HandTrackingSystem.registerSystem()
    }
}

