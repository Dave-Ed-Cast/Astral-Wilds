//
//  LightingConfigurable.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 07/11/24.
//

import Foundation
import SwiftUI
import RealityKit

protocol LightConfigurable {
    func configureLighting(
        resource environment: EnvironmentResource,
        withShadow castShadow: Bool,
        for entity: Entity?
    )
}

extension Entity: LightConfigurable {
    func configureLighting(
        resource environment: EnvironmentResource,
        withShadow castShadow: Bool,
        for entity: Entity? = nil
    ) {
        self.components.set(ImageBasedLightComponent(source: .single(environment)))
        self.components.set(ImageBasedLightReceiverComponent(imageBasedLight: entity ?? self))
        self.components.set(GroundingShadowComponent(castsShadow: castShadow))
    }
}
