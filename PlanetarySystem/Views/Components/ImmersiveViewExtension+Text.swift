//
//  ImmersiveViewExtension+Text.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 08/11/24.
//

import Foundation
import RealityKit
import SwiftUI

extension ImmersiveView {
    
    func textTimer(entity: Entity, environment: EnvironmentResource, content: RealityViewContent) {
                
        let updateTextInterval: TimeInterval = 5.0
        
        timer = Timer.scheduledTimer(withTimeInterval: updateTextInterval, repeats: true) { _ in
            
            let text = (duration == 0) ? (textArray.minuteArray[currentStep]) : textArray.threeMinutesArray[currentStep]
            
            updateStep()
            withAnimation {
                updateTextEntities()
            }
            textEntities = createCurvedTextEntities(text: text, environment: environment, referenceEntity: entity)
            
            for text3D in textEntities {
                content.add(text3D)
            }
        }
    }
    
    func updateTextEntities() {
        for entity in textEntities {
            entity.removeFromParent()
        }
    }
    
    /// This uses the generateText function for 3D text
    ///
    /// The intended way to use this is to have a string, then extract every character.
    /// After that calculate the space of each character to have an even spacing
    /// When creating the text, the curve is calculated with an angle.
    /// Each and every character is rotated in a way to look at the user.
    ///
    /// Parameters suchs as `radius` are fundamental for the curve.
    /// The higher the radius, the more the curve is pronounced
    /// - Parameters:
    ///   - text: The text to cut in single characters
    ///   - environment: The lighting resource
    ///   - referenceEntity: The reference for the lighting
    /// - Returns: Returns a model entity to use
    func createCurvedTextEntities(text: String, environment: EnvironmentResource, referenceEntity: Entity) -> [ModelEntity] {
        
        let radius: Float = 3.0
        let yPosition: Float = 1.35
        let letterPadding: Float = 0.02
        
        var totalAngularSpan: Float = 0.0
        var entities: [ModelEntity] = []
        //angle to center text later
        var currentAngle: Float = -1.8
        
        //extract characters
        for char in text {
            let charEntity = createTextEntity(text: String(char))
            if let boundingBox = charEntity.model?.mesh.bounds {
                let characterWidth = boundingBox.extents.x
                let angleIncrement = (characterWidth + letterPadding) / radius
                totalAngularSpan += angleIncrement
            }
        }
        
        //create curved characters
        for char in text {
            let charEntity = createTextEntity(text: String(char))
            
            if let boundingBox = charEntity.model?.mesh.bounds {
                let characterWidth = boundingBox.extents.x
                let angleIncrement = (characterWidth + letterPadding) / radius
                
                //define the curve
                let x = radius * cos(currentAngle)
                let z = radius * sin(currentAngle)
                
                //make the character look at user
                let lookAtUser = SIMD3(-x, 0, -z)
                
                charEntity.position = SIMD3(x, yPosition, z)
                charEntity.orientation = simd_quatf(from: SIMD3(0, 0, 1), to: lookAtUser)
                charEntity.configureLighting(resource: environment, withShadow: true, for: referenceEntity)
                
                currentAngle += angleIncrement
                
                entities.append(charEntity)
            }
        }
        
        return entities
    }

    func createTextEntity(text: String) -> ModelEntity {
        let mesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.03,
            font: .systemFont(ofSize: 0.12),
            containerFrame: .zero,
            alignment: .center,
            lineBreakMode: .byWordWrapping
        )
        let material = SimpleMaterial(color: UIColor(Color(.white).opacity(0.6)), isMetallic: false)
        return ModelEntity(mesh: mesh, materials: [material])
    }
}
