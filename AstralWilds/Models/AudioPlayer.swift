//
//  AudioPlayer.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 06/11/24.
//

import AVFAudio

/// Handles the audio by playing or stopping the song
class AudioPlayer {
    
    static let shared: AudioPlayer = .init()
    private var player: AVAudioPlayer?
    
    private init() {}
    
    func playSong(
        _ name: String = "space",
        dot ext: String = "mp3",
        numberOfLoops number: Int = 0,
        withVolume volume: Float = 0.25
    ) {
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
