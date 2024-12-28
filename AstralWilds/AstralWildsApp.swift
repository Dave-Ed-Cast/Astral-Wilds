//
//  AstralWildsApp.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 12/05/24.
//

import SwiftUI

/// In this App Type is represented the different windows alongside a function working on the main actor for handling the views
/// It uses an enum "Mode" that is defined from cases that return the associated window id, along with 
/// `needsImmersiveSpace` that defines which one should use an immersive space.
@main
struct AstralWildsApp: App {
    
    fileprivate static let mainScreenWindowID: String = "Main"
    fileprivate static let buttonWindowID: String = "ImmersiveButton"
    fileprivate static let planetsWindowID: String = "MovingPlanets"
    fileprivate static let choosePlanetsWindowID: String = "ChoosePlanets"
    fileprivate static let chooseTimeWindowID: String = "TimeWindow"
    fileprivate static let immersiveTravelWindowId: String = "ImmersiveTravel"
    
    enum Mode: Equatable {
        case mainScreen
        case movingPlanets
        case chooseTime
        case choosePlanetsToMove
        case immersiveTravel
        
        internal var needsImmersiveSpace: Bool {
            return self != .mainScreen && self != .chooseTime
        }
        
        internal var windowId: String {
            switch self {
            case .mainScreen: return mainScreenWindowID
            case .movingPlanets: return planetsWindowID
            case .chooseTime: return chooseTimeWindowID
            case .choosePlanetsToMove: return choosePlanetsWindowID
            case .immersiveTravel: return immersiveTravelWindowId
            }
        }
    }
    
    @State private var mode: Mode = .mainScreen
    @State private var immersiveSpacePresented: Bool = false
    @State private var immersionMode: ImmersionStyle = .full
    @State private var selectedDuration: Int = 0
    @State private var tapLocation: CGPoint = .zero
    @State private var gestureModel = GestureModel()
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(\.pushWindow) private var pushWindow
    
    /// This handles the opening and dismissing of either windows and immersive spaces
    /// - Parameter newMode: is the next mode after interacting within the app
    @MainActor private func setMode(_ newMode: Mode) async {
        
        let oldMode = mode
        mode = newMode
        
        guard newMode != oldMode else { return }
        let immersiveSpaceNotNeeded = (oldMode.needsImmersiveSpace || !newMode.needsImmersiveSpace)
        
        if immersiveSpacePresented && immersiveSpaceNotNeeded {
            
            immersiveSpacePresented = false
            dismissWindow(id: Self.buttonWindowID)
            await dismissImmersiveSpace()
        }
        
        if newMode.needsImmersiveSpace {
            
            immersiveSpacePresented = true
            await openImmersiveSpace(id: newMode.windowId)
            
            //the button needs to appear with the immersive space
            openWindow(id: Self.buttonWindowID)
        } else {
            openWindow(id: newMode.windowId)
        }
        
        if !oldMode.needsImmersiveSpace { dismissWindow(id: oldMode.windowId) }
    }
    
    /// To each view, a window group and an immersive space is associated.
    /// The window group allows dragging around in the mixed/virtual reality.
    /// To each view we associate the environment (immersive or not)
    var body: some Scene {
        
        WindowGroup(id: Self.mainScreenWindowID) {
            MainView()
                .frame(
                    minWidth: 1050, maxWidth: 1200,
                    minHeight: 500, maxHeight: 800
                )
                .environment(\.setMode, setMode)
        }
        .windowResizability(.contentSize)
        
        WindowGroup(id: Self.chooseTimeWindowID) {
            BeforeImmersiveView(durationSelection: $selectedDuration)
                .fixedSize()
                .environment(\.setMode, setMode)
        }
        .windowResizability(.contentSize)
        .defaultWindowPlacement { content, _ in
            return WindowPlacement(
                .utilityPanel,
                size: content.sizeThatFits(.unspecified)
            )
        }
        
        WindowGroup(id: Self.buttonWindowID) {
            ExitImmersiveSpace(mode: $mode)
                .fixedSize()
                .environment(\.setMode, setMode)
        }
        .windowResizability(.contentSize)
        .defaultWindowPlacement { content, context in
            
            let size = content.sizeThatFits(.unspecified)
            if let mainViewWindow = context.windows.first(where: { $0.id == Self.mainScreenWindowID }) {
                
                return WindowPlacement(
                    .trailing(mainViewWindow),
                    size: size
                )
            } else if let chooseTimeWindow = context.windows.first(where: { $0.id == Self.chooseTimeWindowID }) {
                
                return WindowPlacement(.replacing(chooseTimeWindow))
            }
            return WindowPlacement(.none)
        }
        
        ImmersiveSpace(id: Self.planetsWindowID) {
            MovingPlanets()
                .environment(gestureModel)
                .environment(\.setMode, setMode)
            
        }
        .immersionStyle(selection: $immersionMode, in: .full)
        
        ImmersiveSpace(id: Self.choosePlanetsWindowID) {
            withAnimation(.easeInOut) {
                MovePlanetsYouChoose()
                    .environment(gestureModel)
                    .environment(\.setMode, setMode)
            }
        }
        .immersionStyle(selection: $immersionMode, in: .full)
        
        ImmersiveSpace(id: Self.immersiveTravelWindowId) {
            withAnimation(.easeInOut) {
                ImmersiveView(duration: $selectedDuration)
                    .environment(gestureModel)
                    .environment(\.setMode, setMode)
            }
        }
        .immersionStyle(selection: $immersionMode, in: .full)
    }
}
