//
//  PlanetarySystemApp.swift
//  PlanetarySystem
//
//  Created by Davide Castaldi on 12/05/24.
//

import SwiftUI
import RealityKitContent

@main
struct PlanetarySystemApp: App {
    
    private static let mainScreenWindowID: String = "main"
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
    
    @State private var mode: Mode = .mainScreen
    @State private var immersiveSpacePresented: Bool = false
    @State private var immersionStyle: ImmersionStyle = .mixed
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    init() {
        RealityKitContent.GestureComponent
            .registerComponent()
    }
    // this are the variables needed for the immersive space
    @State var immersionMode: ImmersionStyle = .full
    @State private var selectedDuration: Int = 60
    
    @MainActor private func setMode(_ newMode: Mode) async {
        let oldMode = mode
        mode = newMode
        
        print("old mode: \(oldMode)")
        print("new mode: \(mode)")
        
        guard newMode != oldMode else { return }
        
        let immersiveSpaceNotNeeded = (oldMode.needsImmersiveSpace || !newMode.needsImmersiveSpace)
        let oldModeNoImmersiveSpaceNeeded = (oldMode == .mainScreen || oldMode == .chooseTime)

        if immersiveSpacePresented && immersiveSpaceNotNeeded {
            immersiveSpacePresented = false
            await dismissImmersiveSpace()
            print("dismiss immersive space with id: \(oldMode.windowId)")
        }
        
        if newMode.needsImmersiveSpace {
            immersiveSpacePresented = true
            await openImmersiveSpace(id: newMode.windowId)
            print("opening immersive space with id: \(newMode.windowId)")
        } else {
            openWindow(id: newMode.windowId)
            print("opening: \(newMode.windowId)")
        }
        
        if !oldMode.needsImmersiveSpace {
            dismissWindow(id: oldMode.windowId)
            print("dismissing: \(oldMode.windowId)")
        }
    }
    
    var body: some Scene {
        //MARK: we define the views to call and dismiss on command with id
        
        Group {
            WindowGroup(id: Self.mainScreenWindowID) {
                ContentView()
                    .environment(\.setMode, setMode)
            }
            
            WindowGroup(id: Self.chooseTimeWindowID) {
                BeforeImmersiveView()
                    .environment(\.setMode, setMode)
            }
            
            //same thing here
            ImmersiveSpace(id: Self.planetsWindowID) {
                Planets()
                    .environment(\.setMode, setMode)
            }
            .immersionStyle(selection: $immersionMode, in: .full)
            
            ImmersiveSpace(id: Self.planetsDoItYourselfWindowID) {
                ZStack {
                    PlanetsDIY()
                        .environment(\.setMode, setMode)
                    
                    Button {
                        Task { await setMode(.mainScreen) }
                    } label: {
                        Text("Go back to reality")
                            .font(.title3)
                    }
                    .frame(width: 250, height: 100)
                    .opacity(0.5)
                }
            }
            .immersionStyle(selection: $immersionMode, in: .full)
            
            ImmersiveSpace(id: Self.immersiveSpaceWindowId) {
                ZStack {
                    ImmersiveView(duration: $selectedDuration)
                        .environment(\.setMode, setMode)
                    Button {
                        Task { await setMode(.mainScreen) }
                    } label: {
                        Text("Go back to reality")
                            .font(.title3)
                    }
                    .frame(width: 250, height: 100)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding()
                }
            }
            .immersionStyle(selection: $immersionMode, in: .full)
        }
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
