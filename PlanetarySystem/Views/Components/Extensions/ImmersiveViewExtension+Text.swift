//
//  ImmersiveViewExtension+Text.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 08/11/24.
//

import RealityKit
import RealityKitContent
import SwiftUI

extension ImmersiveView {
    
    /// Handles the timer to generate new text according to the duration of the travel
    /// - Parameters:
    ///   - environment: The lighting resource used for an inner helper function
    ///   - content: The reality view
    func textTimer(environment: EnvironmentResource, content: RealityViewContent) {
                
        let updateTextInterval: TimeInterval = 5.0
        
        timer = Timer.scheduledTimer(withTimeInterval: updateTextInterval, repeats: true) { _ in
            
            let text = (duration == 0) ? (textArray.minuteArray[currentStep]) : textArray.threeMinutesArray[currentStep]
            
            updateStep()
            
            Task { @MainActor in
                
                let text3D = textCurver.curveText(
                    text,
                    configuration: .init(radius: 3.0, yPosition: 1.0)
                )
                
                if let environment = try? await EnvironmentResource(named: "studio") {
                    text3D.configureLighting(resource: environment, withShadow: false)
                    content.add(text3D)

                    withAnimation {
                        updateTextEntities(text3D)
                    }
                }
                
                try? await Task.sleep(nanoseconds: 150_000_000)
            }
        }
    }
    
    func updateTextEntities(_ entity: Entity) {
        
        textEntity?.removeFromParent()
        textEntity = entity
    }
    
    /// Generates 3D curved text using the `generateText` function.
    ///
    /// Provide a string, and the function will calculate spacing for each character along a curved path.
    /// Each character is angled to face the user, creating a curved effect.
    /// Adjust `radius` to control the curve: a larger radius creates a gentler curve, while a smaller radius makes it more pronounced.
    /// - Parameters:
    ///   - text: The text to cut in single characters
    ///   - environment: The lighting resource
    /// - Returns: Returns a model entity to use
    func createCurvedText(text: String, environment: EnvironmentResource) -> [ModelEntity] {
        
        let radius: Float = 3.0
        let yPosition: Float = 1.35
        let letterPadding: Float = 0.02
        
        var totalAngularSpan: Float = 0.0
        var entities: [ModelEntity] = []
        //angle to center text later
        var currentAngle: Float = -1.93
        
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
                let z = radius * sin(currentAngle) - 0.3
                
                //make the character look at user
                let lookAtUser = SIMD3(-x, 0, -z)
                
                charEntity.position = SIMD3(x, yPosition, z)
                charEntity.orientation = simd_quatf(from: SIMD3(0, 0, 1), to: lookAtUser)
                charEntity.configureLighting(resource: environment, withShadow: true)
                
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
