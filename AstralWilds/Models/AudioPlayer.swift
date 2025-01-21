//
//  AudioPlayer.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 06/11/24.
//

import AVFAudio

/// Handles the audio by playing or stopping the song
final class AudioPlayer: Sendable {
    
    static let shared: AudioPlayer = .init()
    
    private init() {}
    
    func createPlayer(
        _ name: String = "space",
        dot ext: String = "mp3",
        numberOfLoops number: Int = 0,
        withVolume volume: Float = 0.25
    ) -> AVAudioPlayer? {
        guard let path = Bundle.main.url(forResource: name, withExtension: ext) else {
            fatalError("Cannot find path for resource: \(name).\(ext)")
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: path)
            player.numberOfLoops = number
            player.volume = volume
            return player
        } catch {
            fatalError("Failed to initialize AVAudioPlayer: \(error)")
        }
    }
}
