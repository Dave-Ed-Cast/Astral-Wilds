//
//  PlanetarySystemTests.swift
//  PlanetarySystemTests
//
//  Created by Davide Castaldi on 07/11/24.
//

import Testing
@testable import PlanetarySystem

struct PlanetarySystemTests {
    
    let audioPlayer = AudioPlayer.shared

    @Test func testForbiddenAudio() async throws {
        
        let name = "song"
        let dot = ".wav"
        let numberOfLoops: Int = 0
        let volume: Double = 0.5
        
        let audio = audioPlayer.playSong(name, dot: dot, numberOfLoops: numberOfLoops, withVolume: Float(volume))
        #expect(audio == nil)
        

    }

}
