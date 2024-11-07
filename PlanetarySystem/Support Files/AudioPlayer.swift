//
//  AudioPlayer.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 06/11/24.
//

import Foundation
import AVFAudio

//this is for music
class AudioPlayer {
    
    //static var shared: AVAudioPlayer = AVAudioPlayer()
    
    @MainActor static let shared: AudioPlayer = .init()
    
    private var player: AVAudioPlayer?
    
    func playSong(_ name: String, dot ext: String, numberOfLoops number: Int, withVolume volume: Float) {
        let path = Bundle.main.url(forResource: "\(name)", withExtension: "\(ext)")!
        do {
            player = try AVAudioPlayer(contentsOf: path)
        } catch {
            fatalError("cannot find path")
        }
        
        guard let player else { return }
        
        player.numberOfLoops = number
        player.volume = volume
        player.play()
    }
    
    func stopSong() {
        player?.stop()
    }
    
    @MainActor private init() {}
}
