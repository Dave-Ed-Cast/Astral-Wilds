//
//  AudioPlayer.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 03/03/25.
//

import Foundation
import RealityKit
import RealityKitContent

@MainActor @Observable
final class AudioPlayer {
    
    var entityHolder: Entity = .init()
    
    /// Has the role of playing the audio music for the travel
    func playAudio(_ audioEntityName: String) {
        guard let music = entityHolder.findEntity(named: audioEntityName) else {
            print("audio holder not found")
            return
        }
        
        guard let audioLibrary = music.components[AudioLibraryComponent.self] else {
            print("audio library not found")
            return
        }
        guard let audioResource = audioLibrary.resources.first?.value else {
            print("music not found")
            return
        }
        entityHolder.playAudio(audioResource)
    }
}
