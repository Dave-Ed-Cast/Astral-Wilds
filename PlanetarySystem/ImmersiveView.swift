//
//  TravelToMars.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 15/05/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {

    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
        
    var body: some View {
        RealityView { content in
            
            guard let skyBoxEntity = createSkyBox() else {
                print("error")
                return
            }
            
            content.add(skyBoxEntity)
        }
        .onAppear {
            //but before that let's get rid of everything else
            dismissWindow(id: "main")
        }
    }
    
    private func createSkyBox() -> Entity? {
        //mesh
        let largeSphere = MeshResource.generateSphere(radius: 1000)
        
        //material
        var skyBoxMaterial = UnlitMaterial()
        
        do {
            let texture = try TextureResource.load(named: "StarryNight")
            skyBoxMaterial.color = .init(texture: .init(texture))
        } catch {
            print(error)
        }
        
        //skybox
        let skyBoxEntity = Entity()
        skyBoxEntity.components.set(
            ModelComponent(
                mesh: largeSphere,
                materials: [skyBoxMaterial]
            )
        )
        
        skyBoxEntity.scale *= .init(x: -1, y: 1, z: 1)
        
        return skyBoxEntity
    }
}

#Preview {
    ImmersiveView()
}
