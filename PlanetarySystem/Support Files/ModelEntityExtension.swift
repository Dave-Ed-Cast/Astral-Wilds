//
//  ModelEntityExtension.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 06/11/24.
//

import Foundation
import RealityKit

extension ModelEntity {
    
    @MainActor func setUpLightForEntity(
        resourceName name: String,
        for entity: Entity,
        withShadow shadow: Bool
    ) async {
        do {
            let environment = try await EnvironmentResource(named: name)
            entity.components.set(ImageBasedLightComponent(source: .single(environment)))
            entity.components.set(ImageBasedLightReceiverComponent(imageBasedLight: entity))
            entity.components.set(GroundingShadowComponent(castsShadow: shadow))
        } catch {
            print("Failed to load environment resource: \(error)")
        }
    }
}
