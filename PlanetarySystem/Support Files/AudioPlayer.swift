//
//  AudioPlayer.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 06/11/24.
//

import Foundation
import AVFAudio

@MainActor class AudioPlayer {
    
    static let shared: AudioPlayer = .init()
    private var player: AVAudioPlayer?
    
    private init() {}
    
    func playSong(_ name: String, dot ext: String, numberOfLoops number: Int, withVolume volume: Float) {
        guard let path = Bundle.main.url(forResource: name, withExtension: ext) else {
            fatalError("Cannot find path for resource: \(name).\(ext)")
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: path)
        } catch {
            fatalError("Failed to initialize AVAudioPlayer: \(error)")
        }
        
        guard let player = player else { return }
        
        player.numberOfLoops = number
        player.volume = volume
        player.play()
    }
    
    func stopSong() { player?.stop() }
    
    
}
