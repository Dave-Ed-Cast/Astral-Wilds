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
    /// ### Example Usage:
    /// ```swift
    /// someView.conditionalModifier(showDoneButton) { view in
    ///     view.overlay(alignment: .bottom) {
    ///         Button {
    ///             counter += 1
    ///         } label: {
    ///             Text("Ok!")
    ///         }
    ///         .buttonStyle(.bordered)
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - booleanCondition: A Boolean value that determines whether the transformation should be applied.
    ///   - transformingClosure: A closure that transforms the view content when the condition is `true`.
    /// - Returns: A modified view if the condition is met; otherwise, the original view.
    @ViewBuilder func conditionalModifier<Content: View>(
        _ booleanCondition: Bool,
        transformingClosure: (Self) -> Content
    ) -> some View {
        
        if booleanCondition { transformingClosure(self) } else { self }
    }
    
    
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
