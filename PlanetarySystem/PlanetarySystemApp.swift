//
//  PlanetarySystemApp.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

import SwiftUI
import RealityKitContent

/// In this App Type is represented the different windows alongside a function working on the main actor for handling the views
/// It uses an enum "Mode" that is defined from cases that return the associated window id, along with 
/// `needsImmersiveSpace` that defines which one should use an immersive space.
@main
struct PlanetarySystemApp: App {
    
    private static let mainScreenWindowID: String = "main"
    private static let buttonWindowID: String = "Button"
    private static let planetsWindowID: String = "planets"
    private static let planetsDoItYourselfWindowID: String = "DIY"
    private static let chooseTimeWindowID: String = "Before"
    private static let immersiveSpaceWindowId: String = "ImmersiveView"
    
    enum Mode: Equatable {
        case mainScreen
        case planets
        case chooseTime
        case choosePlanetsToMove
        case immersiveSpace
        
        var needsImmersiveSpace: Bool {
            return self != .mainScreen && self != .chooseTime
        }
        
        fileprivate var windowId: String {
            switch self {
            case .mainScreen: return mainScreenWindowID
            case .planets: return planetsWindowID
            case .chooseTime: return chooseTimeWindowID
            case .choosePlanetsToMove: return planetsDoItYourselfWindowID
            case .immersiveSpace: return immersiveSpaceWindowId
            }
        }
    }
    
    init() {
        RealityKitContent.GestureComponent
            .registerComponent()
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
    
    /// This handles the opening and dismissing of either windows and immersive spaces
    /// - Parameter newMode: is the next mode after interacting within the app
    @MainActor private func setMode(_ newMode: Mode) async {
        
        let oldMode = mode
        mode = newMode
        
        guard newMode != oldMode else { return }
        let immersiveSpaceNotNeeded = (oldMode.needsImmersiveSpace || !newMode.needsImmersiveSpace)
        
        if immersiveSpacePresented && immersiveSpaceNotNeeded {
            
            immersiveSpacePresented = false
            await dismissImmersiveSpace()
        }
        
        if newMode.needsImmersiveSpace {
            
            immersiveSpacePresented = true
            await openImmersiveSpace(id: newMode.windowId)
            
            //the button window needs to appear when the immersive space appears
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
            ContentView()
                .fixedSize()
                .environment(\.setMode, setMode)
        }
        .windowResizability(.contentMinSize)
        
        WindowGroup(id: Self.chooseTimeWindowID) {
            BeforeImmersiveView(durationSelection: $selectedDuration)
                .frame(width: 600, height: 380)
                .frame(alignment: .front)
                .environment(\.setMode, setMode)
        }
        .windowResizability(.contentSize)
        
        WindowGroup(id: Self.buttonWindowID) {
            ExitImmersiveSpace(mode: $mode)
                .fixedSize(horizontal: true, vertical: true)
                .frame(width: 300, height: 120)
                .environment(\.setMode, setMode)
        }
        .windowResizability(.contentSize)
        
        ImmersiveSpace(id: Self.planetsWindowID) {
            withAnimation(.easeInOut) {
                MovePlanets()
                    .environment(gestureModel)
                    .environment(\.setMode, setMode)
            }
        }
        .immersionStyle(selection: $immersionMode, in: .full)
        
        ImmersiveSpace(id: Self.planetsDoItYourselfWindowID) {
            withAnimation(.easeInOut) {
                MovePlanetsYouChoose()
                    .environment(gestureModel)
                    .environment(\.setMode, setMode)
            }
        }
        .immersionStyle(selection: $immersionMode, in: .full)
        
        ImmersiveSpace(id: Self.immersiveSpaceWindowId) {
            withAnimation(.easeInOut) {
                ImmersiveView(duration: $selectedDuration)
                    .environment(gestureModel)
                    .environment(\.setMode, setMode)
            }
        }
        .immersionStyle(selection: $immersionMode, in: .full)
    }
}

struct SetModeKey: EnvironmentKey {
    typealias Value = (PlanetarySystemApp.Mode) async -> Void
    static let defaultValue: Value = { _ in }
}

extension EnvironmentValues {
    var setMode: SetModeKey.Value {
        get { self[SetModeKey.self] }
        set { self[SetModeKey.self] = newValue }
    }
}
