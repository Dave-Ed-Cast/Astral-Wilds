//
//  ImmersiveViewExtension+Text.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 08/11/24.
//

import SwiftUI
import RealityKit

extension ImmersiveTravel {
    
//    /// Handles the timer to generate new text according to the duration of the travel
//    /// - Parameters:
//    ///   - environment: The lighting resource used for an inner helper function
//    ///   - content: The reality view
//    func textTimer(environment: EnvironmentResource, content: RealityViewContent) {
//                
//        let updateTextInterval: TimeInterval = 5.0
//        
//        let configuration = textCurver.Configuration(radius: 3.5, yPosition: 1.1)
//        
//        timer = Timer.scheduledTimer(withTimeInterval: updateTextInterval, repeats: true) { _ in
//            
//            let text = textArray[currentStep]
//            
//            updateStep()
//            
//            Task { @MainActor in
//                
//                let text3D = textCurver.curveText(
//                    text,
//                    configuration: configuration
//                )
//                
//                if let environment = try? await EnvironmentResource(named: "studio") {
//                    text3D.configureLighting(resource: environment, withShadow: false)
//                    content.add(text3D)
//
//                    withAnimation {
//                        textEntity?.removeFromParent()
//                        textEntity = text3D
//                    }
//                }
//            }
//        }
//    }
}
