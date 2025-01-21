////
////  TimerManager.swift
////  AstralWilds
////
////  Created by Davide Castaldi on 13/01/25.
////
//
//import Foundation
//
//@MainActor
//final class TimerManager: Sendable {
//    
//    static let shared = TimerManager()
//    private var timers: [String: Timer] = [:]
//    
//    func asyncTimer(id identifier: String, timeInterval interval: TimeInterval, action: @escaping @Sendable () async -> Void) {
//        invalidateTimer(id: identifier)
//                
//        let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
//            Task { @MainActor in
//                await  action()
//            }
//        }
//        
//        timers[identifier] = timer
//    }
//    
//    func invalidateTimer(id identifier: String) {
//        if let timer = timers[identifier] {
//            timer.invalidate()
//            timers.removeValue(forKey: identifier)
//            print("stopped timer \(identifier)")
//        } else {
//            print("No active timer with id \(identifier)")
//        }
//    }
//}
