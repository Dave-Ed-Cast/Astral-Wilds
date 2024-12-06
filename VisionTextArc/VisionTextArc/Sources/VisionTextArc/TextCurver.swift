//
//  TextCurver.swift
//  VisionTextArc
//
//  Created by Davide Castaldi on 15/11/24.
//

import SwiftUI
import RealityKit

@MainActor
@available(visionOS 1.0, *, iOS 13.0, *)
public enum TextCurver: Sendable {
        
    /// A configuration object for customizing 3D curved text.
    ///
    /// This structure defines parameters for styling and positioning text along a 3D curve.
    /// It provides fine-grained control over text appearance, material properties, and layout.
    ///
    /// - Properties:
    ///   - `fontSize`: The size of the font used for rendering the text.
    ///   - `font`: The font resource used for creating the text geometry.
    ///   - `extrusionDepth`: The depth of the 3D extrusion applied to each character, creating a volumetric effect.
    ///   - `color`: The color applied to the text material.
    ///   - `roughness`: The roughness of the text material's surface, affecting light scattering.
    ///   - `isMetallic`: A boolean value indicating whether the text material exhibits metallic properties.
    ///   - `radius`: The radius of the curve on which the text is laid out. Larger values position the text farther from the center of curvature.
    ///   - `offset`: The angular position of the text along the curve, measured in radians.
    ///   - `yPosition`: The Y-axis position of the text entity (vertical head movement axis).
    ///   - `letterPadding`: The spacing between consecutive letters, controlling text density along the curve.
    ///   - `containerFrame`: The 2D frame defining the text container size and positioning within the scene.
    ///   - `alignment`: The horizontal alignment of the text within its container (e.g., left, center, right).
    ///   - `lineBreakMode`: The strategy for handling line breaks, defining how text wraps within the container frame.
    ///
    /// - See also: `curveText(_:configuration:)` for how this configuration is applied.
    /// 
    
    @MainActor
    public struct Configuration {
        public var fontSize: CGFloat
        public var font: MeshResource.Font
        public var extrusionDepth: Float
        public var color: UIColor
        public var roughness: MaterialScalarParameter
        public var isMetallic: Bool
        public var radius: Float
        public var offset: Float
        public var yPosition: Float
        public var letterPadding: Float
        public var containerFrame: CGRect
        public var alignment: CTTextAlignment
        public var lineBreakMode: CTLineBreakMode
        
        public init(
            fontSize: CGFloat = 0.12,
            font: MeshResource.Font? = nil,
            extrusionDepth: Float = 0.03,
            color: UIColor = .white,
            roughness: MaterialScalarParameter = 0,
            isMetallic: Bool = false,
            radius: Float = 3.0,
            offset: Float = 0.0,
            yPosition: Float = .zero,
            letterPadding: Float = 0.02,
            containerFrame: CGRect = .zero,
            alignment: CTTextAlignment = .center,
            lineBreakMode: CTLineBreakMode = .byCharWrapping
        ) {
            
            self.fontSize = fontSize
            self.font = font ?? .systemFont(ofSize: fontSize)
            self.extrusionDepth = extrusionDepth
            self.color = color
            self.roughness = roughness
            self.isMetallic = isMetallic
            self.radius = max(radius, 0.01)
            self.offset = offset
            self.yPosition = yPosition
            self.letterPadding = max(letterPadding, 0)
            self.containerFrame = containerFrame
            self.alignment = alignment
            self.lineBreakMode = lineBreakMode
        }
    }
    
    /// Generates 3D curved text with customizable parameters.
    ///
    /// This function creates a 3D text effect by arranging the text along a curve.
    /// You can adjust many different parameters of the text in 3D space.
    ///
    /// - Parameters:
    ///   - text: The text to display.
    ///   - configuration: An object specifying the parameters of the text on the curve.
    ///
    /// - Returns:
    ///   An `Entity` instance that represents the generated 3D text, ready for display.
    /// - See also: `Configuration` for detailed control over text appearance and layout.
    ///
    /// The following example is a simple how to use:
    ///
    ///     let foo = TextCurver.self
    ///
    ///     let text1 = foo.curveText(string1)
    ///     let text2 = foo.curveText(string2, configuration: .init(font: UIFont(name: "Marion", size: 0.2)))
    ///     let text3 = foo.curveText(string3, configuration: .init(color: .green, roughness: 1.0, isMetallic: true))
    ///     let text4 = foo.curveText(string4, configuration: .init(offset: -.pi / 2))
    ///     let text5 = foo.curveText(string5, configuration: .init(extrusionDepth: 0.15, radius: 4.0))
    ///     let text6 = foo.curveText(string6, configuration: .init(fontSize: 0.15, letterPadding: 0.05))
    ///
    @MainActor
    public static func curveText(_ text: String, configuration: Configuration = .init()) -> Entity {
        
        let material = configureMat(configuration)
        var characters: [(entity: ModelEntity, width: Float)] = []
        
        for char in text {
            if let charEntity = configureChar(char, config: configuration, mat: material) {
                characters.append(charEntity)
            }
        }
        
        let totalAngularSpan = calculateAngularSpan(
            chars: characters,
            letterPadding: configuration.letterPadding,
            radius: configuration.radius
        )
        
        let finalEntity = charactersPosition(
            characters,
            radius: configuration.radius,
            offset: configuration.offset,
            totalAngularSpan: totalAngularSpan,
            letterPadding: configuration.letterPadding,
            yPosition: configuration.yPosition
        )
        
        return finalEntity
    }
    
    /// Configuration of the material
    /// - Parameter config: The parameters from the user
    /// - Returns: The simple material with the configuration
    fileprivate static func configureMat(_ config: Configuration) -> SimpleMaterial {
        return SimpleMaterial(
            color: config.color,
            roughness: config.roughness,
            isMetallic: config.isMetallic
        )
    }
    
    /// Configuration of the 3D character
    /// - Parameters:
    ///   - char: The next character in line from the string
    ///   - config: The parameters from the user
    ///   - mat: The material built on top of user request
    /// - Returns: A 3D letter entity and its width as a float.
    fileprivate static func configureChar(
        _ char: Character,
        config: Configuration,
        mat: SimpleMaterial
    ) -> (entity: ModelEntity, width: Float)? {
        
        let mesh = MeshResource.generateText(
            String(char),
            extrusionDepth: config.extrusionDepth,
            font: config.font,
            containerFrame: config.containerFrame,
            alignment: config.alignment,
            lineBreakMode: config.lineBreakMode
        )
        
        let charEntity = ModelEntity(mesh: mesh, materials: [mat])
        guard let boundingBox = charEntity.model?.mesh.bounds else { return nil }
        
        let characterWidth = boundingBox.extents.x
        return (entity: charEntity, width: characterWidth)
    }
    
    /// Calculates the angular span between each 3D letter generated
    /// - Parameters:
    ///   - chars: The 3D letter entity and its width as a float.
    ///   - config: The parameters from the user
    ///   - mat: The material built on top of user request
    /// - Returns: Returns the total angular span value
    fileprivate static func calculateAngularSpan(
        chars: [(entity: ModelEntity, width: Float)],
        letterPadding: Float,
        radius: Float
    ) -> Float {
        
        return chars.reduce(0.0) { span, charEntity in
            span + (charEntity.width + letterPadding) / radius
        }
    }
    
    /// Calculates the angular span between each 3D letter generated
    /// - Parameters:
    ///   - chars: The array 3D letters entity and its width as a float.
    ///   - radius: The selected radius from the user
    ///   - offset: The selected offset from the user
    ///   - totalAngularSpan: The angular span derived from the generation of 3D letters
    ///   - letterPadding: The selected padding from the user
    /// - Returns: Returns the 3D string entity with all the parameters applied
    fileprivate static func charactersPosition(
        _ chars: [(entity: ModelEntity, width: Float)],
        radius: Float,
        offset: Float,
        totalAngularSpan: Float,
        letterPadding: Float,
        yPosition: Float
    ) -> Entity {
        
        let finalEntity = Entity()
        var currentAngle: Float = -totalAngularSpan / 2.0 + offset
        
        for (char, characterWidth) in chars {
            let angleIncrement = (characterWidth + letterPadding) / radius
            
            let x = radius * sin(currentAngle)
            let z = -radius * cos(currentAngle)
            
            let lookAtUser = SIMD3(x, 0, z)
            let lookAtUserNormalized = normalize(lookAtUser)
            
            char.orientation = simd_quatf(from: SIMD3(0, 0, -1), to: lookAtUserNormalized)
            char.position = SIMD3(x, 0, z)
            
            finalEntity.addChild(char)
            currentAngle += angleIncrement
        }
        
        finalEntity.position.y = yPosition
        return finalEntity
    }
    
}
