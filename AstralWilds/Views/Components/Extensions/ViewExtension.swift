//
//  ViewExtension.swift
//  PlanetarySystem
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
}
