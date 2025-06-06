//
//  ViewExtension.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 04/11/24.
//

import SwiftUI
import RealityKit

extension View {
    
    /// Conditionally transforms the view.
    ///
    /// Use this method to apply a transformation to the view only if the specified condition is true.
    /// If the condition is false, the original view is returned unchanged.
    ///
    /// - Parameters:
    ///   - condition: A Boolean value that determines whether the transformation should be applied.
    ///   - transform: A closure that transforms the view content when the condition is `true`.
    /// - Returns: A modified view if the condition is met; otherwise, the original view.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
    
    /// Performs a depth-first search on the given entity hierarchy to find a child entity with the specified name.
    ///
    /// - Parameters:
    ///   - name: The name of the entity to search for.
    ///   - entity: The root entity from which to begin the search.
    /// - Returns: The entity matching the specified name, or `nil` if not found.
    func findPlanetEntity(for entity: Entity, in name: String) -> Entity? {
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
    
    /// Scales a window according to parameters.
    ///
    /// - Parameters:
    ///   - size: The size of the window
    ///   - baseWidth: The base width of the window you want to enstablish
    ///   - baseHeight: The base height of the window you want to enstablish
    ///   - scale: The scale factor you need
    /// - Returns: The scaled value
    func calculateScale(
        for size: CGSize,
        baseWidth: CGFloat = 500,
        baseHeight: CGFloat = 500,
        scale: CGFloat = 3.0
    ) -> CGFloat {
        let widthScale = size.width / baseWidth
        let heightScale = size.height / baseHeight
        
        return min(max(min(widthScale, heightScale), 1.0), scale)
    }
    
    /// Standard modifiers that are always used in Astral Wilds.
    ///
    /// Avoids having to rewrite three everytime.
    /// - Returns: Simple modifiers to app consistency design.
    func standardModifiers() -> some View {
        self
            .padding()
            .fixedSize()
            .background(.black.opacity(0.4))
    }
}
