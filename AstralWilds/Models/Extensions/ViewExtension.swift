//
//  ViewExtension.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 04/11/24.
//

import SwiftUI
import RealityFoundation

extension View {
    
    /// Finds the planet name through Depth First Search method
    ///
    /// - Parameters:
    ///   - entity: the particular entity
    ///   - name: associated name in the dictionary
    /// - Returns: return that entity with the associated name in the dictionary
    func planetName(for entity: Entity, in name: String) -> Entity? {
        var tempEntityArray = [entity]
        
        while !tempEntityArray.isEmpty {
            let current = tempEntityArray.removeLast()
            if current.name == name {
                return current
            }
            
            tempEntityArray.append(contentsOf: current.children)
        }
        
        return nil
    }
    
    func calculateScale(
        for size: CGSize,
        baseWidth: CGFloat = 500,
        baseHeight: CGFloat = 500,
        scale: CGFloat = 3.0
    ) -> CGFloat {
        let widthScale = size.width / baseWidth
        let heightScale = size.height / baseHeight
        
        // Use the smaller of the two scales, clamped to a reasonable range
        return min(max(min(widthScale, heightScale), 1.0), scale)
    }
}
