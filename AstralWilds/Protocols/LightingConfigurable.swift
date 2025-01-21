//
//  LightingConfigurable.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 07/11/24.
//

import SwiftUI
import RealityKit

/// Protocol that handles only one type of lighting: single
protocol LightConfigurable {
    func configureLighting(
        resource environment: EnvironmentResource,
        withShadow castShadow: Bool,
        for entity: Entity?
    ) async
}

extension Entity: LightConfigurable {
    
    //Protection level must be the same as the protocol
    internal func configureLighting(
        resource environment: EnvironmentResource,
        withShadow castShadow: Bool,
        for entity: Entity? = nil
    ) {
        self.components.set(ImageBasedLightComponent(source: .single(environment)))
        self.components.set(ImageBasedLightReceiverComponent(imageBasedLight: entity ?? self))
        self.components.set(GroundingShadowComponent(castsShadow: castShadow))
    }
}
