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
    @State private var selectedDuration: Int = 60
    
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    /// This handles the opening and dismissing of either windows and immersive spaces
    /// - Parameter newMode: is the next mode after interacting within the app
    @MainActor private func setMode(_ newMode: Mode) async {
        
        let oldMode = mode
        mode = newMode
        
        print(mode)
        
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
            print("opened!")
        } else {
            openWindow(id: newMode.windowId)
        }
        
        if !oldMode.needsImmersiveSpace { dismissWindow(id: oldMode.windowId) }
    }
    
    /// To each view we associate a window group and an immersive space.
    /// The window group allows dragging around in the mixed/virtual reality.
    /// To each view we associate the environment (immersive or not)
    var body: some Scene {
        
        WindowGroup(id: Self.mainScreenWindowID) {
            ContentView()
                .environment(\.setMode, setMode)
        }
        
        WindowGroup(id: Self.chooseTimeWindowID) {
            BeforeImmersiveView()
                .frame(width: 600, height: 380)
                .frame(alignment: .front)
                .environment(\.setMode, setMode)
        }
        .windowResizability(.contentSize)
        
        WindowGroup(id: Self.buttonWindowID) {
            VStack(spacing: 10) {
                Text("Feeling overwhelmed? \nThis is the button to go back.")
                    .font(.headline)
                
                if mode == .immersiveSpace {
                    Text("Spatial audio is playing. \nConsider positioning this window above or underneath your head.")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }
                
                Button {
                    Task { await setMode(.mainScreen) }
                    
                    //the button window needs to be go when the immersive space disappears
                    dismissWindow(id: Self.buttonWindowID)
                } label: {
                    Text("Go back to reality")
                        .font(.headline)
                }
            }
            .onAppear {
                print("rendered!")
            }
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: true, vertical: true)
            .frame(width: 250, height: 120)
            .environment(\.setMode, setMode)
            .padding()
        }
        .windowResizability(.contentSize)
        
        ImmersiveSpace(id: Self.planetsWindowID) {
            withAnimation(.easeInOut) {
                MovePlanets()
                    .environment(\.setMode, setMode)
            }
        }
        .immersionStyle(selection: $immersionMode, in: .full)
        
        ImmersiveSpace(id: Self.planetsDoItYourselfWindowID) {
            withAnimation(.easeInOut) {
                MovePlanetsYouChoose()
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
