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

        if immersiveSpacePresented && immersiveSpaceNotNeeded {
            immersiveSpacePresented = false
            await dismissImmersiveSpace()
            print("dismiss immersive space with id: \(oldMode.windowId)")
            dismissWindow(id: "Button")
        }
        
        if newMode.needsImmersiveSpace {
            immersiveSpacePresented = true
            await openImmersiveSpace(id: newMode.windowId)
            openWindow(id: "Button")
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
            
            WindowGroup(id: Self.buttonWindowID) {
                VStack {
                    Text("Feeling overwhelmed? \nThis is the button to go back.")
                        .font(.title3)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        Task { await setMode(.mainScreen) }
                    } label: {
                        Text("Go back to reality")
                    }
                    .frame(width: 300, height: 100)
                    .frame(alignment: .front)
                }
                .fixedSize(horizontal: true, vertical: true)
                .environment(\.setMode, setMode)
                .padding()
            }
            .windowResizability(.contentSize)
            
            //same thing here
            Group {
                ImmersiveSpace(id: Self.planetsWindowID) {
                    withAnimation(.easeInOut) {
                        Planets()
                            .environment(\.setMode, setMode)
                    }
                }
                .immersionStyle(selection: $immersionMode, in: .full)
                
                ImmersiveSpace(id: Self.planetsDoItYourselfWindowID) {
                    withAnimation(.easeInOut) {
                        PlanetsDIY()
                            .environment(\.setMode, setMode)
                    }
                }
                .immersionStyle(selection: $immersionMode, in: .full)
                
                ImmersiveSpace(id: Self.immersiveSpaceWindowId) {
                    withAnimation(.easeInOut) {
                        ImmersiveView(duration: $selectedDuration)
                            .environment(\.setMode, setMode)
                    }
                }
                .immersionStyle(selection: $immersionMode, in: .full)
            }
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
