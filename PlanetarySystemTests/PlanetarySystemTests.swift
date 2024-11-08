//
//  PlanetarySystemTests.swift
//  PlanetarySystemTests
//
//  Created by Davide Castaldi on 07/11/24.
//

import Testing
import RealityKit
import RealityKitContent

@testable import PlanetarySystem
import Foundation
import SwiftUI

struct PlanetarySystemTests {
    
    let audioPlayer = AudioPlayer.shared

//    @Test func testForbiddenAudio() async throws {
//        
//        let name = "song"
//        let dot = ".wav"
//        let numberOfLoops: Int = 0
//        let volume: Double = 0.5
//        
//        let audio = audioPlayer.playSong(name, dot: dot, numberOfLoops: numberOfLoops, withVolume: Float(volume))
//        #expect(audio == nil)
//    }
//    
//    @Test func finalPlanetPosition() async throws {
//
//        @State var planetTimer: Timer?
//        
//        if let entity = try? await Entity(named: "TravelToMars", in: realityKitContentBundle) {
//            entity.position.z = -51
//            let oneMinuteSpeed: Float = 2.0
//            
//            let velocity = oneMinuteSpeed
//            
//            let updateForMovement: TimeInterval = 1.0 / 60.0
//            let frameMovement = TimeInterval(velocity) * updateForMovement
//            
//            
//            planetTimer = Timer.scheduledTimer(withTimeInterval: updateForMovement, repeats: true) { timer in
//                
//                entity.position.z += Float(frameMovement)
//                print(entity.position.z)
//            }
//            await #expect(entity.position.z > 40.0)
//        }
//    }
}
