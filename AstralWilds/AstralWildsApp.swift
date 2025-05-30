//
//  AstralWildsApp.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 12/05/24.
//

import SwiftUI
import RealityKitContent

/// The main entry point for the AstralWilds app.
///
/// This app manages multiple windows and immersive spaces on visionOS, handling UI transitions on the main actor.
/// It leverages RealityKitContent for immersive experiences and uses different modes (window IDs) to control its lifecycle.
@main
struct AstralWildsApp: App {
    
    // Usually, I put environment variables first; but due to immersionMode dependencies they must go here or Xcode complains.
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    @State private var mode: Mode = .welcome
    @State private var duration: Int = 0
    @State private var sitting: Bool = true
    @State private var immersiveSpacePresented: Bool = false
    @State private var chooseTimeWindowIsOpen: Bool = false
    @State private var immersionStyle: ImmersionStyle = .progressive(0.0...1.0, initialAmount: 1.0)
    
    @State private var gestureRecognizer = GestureRecognizer.shared
        
    /// Represents the different states of the application.
    /// Each mode corresponds to a specific window ID and determines whether an immersive space is needed.
    enum Mode: Equatable {
        
        case welcome, mainScreen, chooseTime
        case movingPlanets, choosePlanetsToMove, immersiveTravel
        
        /// Indicates if the mode called upon,requires an immersive space or not.
        fileprivate var needsImmersiveSpace: Bool {
            switch self {
            case .mainScreen, .chooseTime, .welcome: return false
            default: return true
            }
        }
        
        /// Indicates if the mode called upon, requires the last window to be closed or not.
        fileprivate var needsLastWindowClosed: Bool { return self == .mainScreen }
        
        /// Returns the associated identifier for the mode.
        @MainActor fileprivate var windowId: String {
            switch self {
            case .welcome: return ModeIDs.welcomeWindowID
            case .mainScreen: return ModeIDs.mainScreenWindowID
            case .movingPlanets: return ModeIDs.planetImmersiveID
            case .chooseTime: return ModeIDs.chooseTimeWindowID
            case .choosePlanetsToMove: return ModeIDs.choosePlanetsImmersiveID
            case .immersiveTravel: return ModeIDs.immersiveTravelImmersiveId
            }
        }
    }
    
    /// Initializes the AstralWilds app by registering the RealityKit gesture component.
    init() { RealityKitContent.GestureComponent.registerComponent() }
    
    var body: some Scene {
        Group {
            WindowGroup(id: ModeIDs.welcomeWindowID) {
                WelcomeView()
                    .background(.black.opacity(0.4))
                    .frame(
                        minWidth: 520, maxWidth: 1000,
                        minHeight: 450, maxHeight: 930
                    )
            }
            .windowResizability(.contentSize)
            .defaultSize(width: 520, height: 450)
            
            WindowGroup(id: ModeIDs.mainScreenWindowID) {
                MainView()
                    .frame(
                        minWidth: 700, maxWidth: 1000,
                        minHeight: 550, maxHeight: 900
                    )
                    .background(.black.opacity(0.4))
                    .fixedSize()
                    .opacity(chooseTimeWindowIsOpen ? 0.35 : 1)
                    .animation(.default, value: chooseTimeWindowIsOpen)
            }
            .windowResizability(.contentSize)
            .defaultSize(width: 700, height: 550)
            
            WindowGroup(id: ModeIDs.chooseTimeWindowID) {
                ChooseTimeView(durationSelection: $duration, sitting: $sitting)
                    .fixedSize()
                    .background(.black.opacity(0.4))
                    .onAppear { chooseTimeWindowIsOpen = true }
                    .onDisappear { chooseTimeWindowIsOpen = false }
            }
            .windowResizability(.contentSize)
            .defaultWindowPlacement { content, _ in
                WindowPlacement(
                    .utilityPanel,
                    size: content.sizeThatFits(.unspecified)
                )
            }
            
            WindowGroup(id: ModeIDs.buttonWindowID) {
                Group {
#if targetEnvironment(simulator)
                    ExitImmersiveSpaceButton(mode: $mode)
#elseif !targetEnvironment(simulator)
                    ExitImmersiveSpaceGesture()
#endif
                }
                .frame(width: 350, height: 180)
                .background(.black.opacity(0.4))
                .fixedSize()
            }
            .persistentSystemOverlays(.hidden)
            .windowResizability(.contentSize)
            .defaultWindowPlacement { content, context in
                let size = content.sizeThatFits(.unspecified)
                if let mainViewWindow = context.windows.first(where: { $0.id == ModeIDs.mainScreenWindowID }) {
                    return WindowPlacement(.below(mainViewWindow), size: size)
                }
                return WindowPlacement(.none)
            }
            
            Group {
                ImmersiveSpace(id: ModeIDs.planetImmersiveID) {
                    MovingPlanets()
                }
                ImmersiveSpace(id: ModeIDs.choosePlanetsImmersiveID) {
                    MovePlanetsYouChoose()
                }
                ImmersiveSpace(id: ModeIDs.immersiveTravelImmersiveId) {
                    ImmersiveTravel(duration: $duration, sitting: $sitting)
                }
            }
            .environment(gestureRecognizer)
            .immersionStyle(selection: $immersionStyle, in: .mixed, .progressive, .full)
        }
        .environment(\.setMode, setMode)
    }
    
    /// Manages transitions between application modes by orchestrating the opening and dismissal of windows and immersive spaces.
    ///
    /// Each transition incorporates a brief pause to mitigate potential race conditions and concurrency issues on visionOS.
    /// The function adheres to the following guidelines:
    /// ```
    /// When opening a new window, follow this sequence:
    /// 1. Open the window.
    /// 2. Pause briefly to mitigate race conditions.
    /// 3. Optionally, dismiss any window if necessary.
    ///
    /// When opening an immersive space, use the same sequence:
    /// 1. Open the immersive space.
    /// 2. Pause briefly.
    /// 3. Optionally, dismiss the previously active immersive space.
    ///
    /// Whenever an immersive space must be closed, the flow can be whatever.
    /// ```
    /// - Parameter newMode: The new mode to transition to.
    @MainActor private func setMode(_ newMode: Mode) async {
        let oldMode = mode
        guard newMode != oldMode else { return }
        
        mode = newMode
        print("\nTransitioning from \(oldMode) to \(newMode)")
        
        if immersiveSpacePresented {
            await transitionFromImmersiveSpace(from: oldMode, to: newMode)
        } else {
            await transitionFromWindowMode(from: oldMode, to: newMode)
        }
    }

    

    @MainActor private func transitionFromImmersiveSpace(from oldMode: Mode, to newMode: Mode) async {
        print("Transitioning from immersive space")
        
        // Always dismiss immersive space and button window first
        dismissWindow(id: ModeIDs.buttonWindowID)
        await dismissImmersiveSpace()
        immersiveSpacePresented = false
        
        if newMode.needsImmersiveSpace {
            // Direct immersive-to-immersive transition
            await openNewImmersiveSpace(for: newMode, dismissingOld: oldMode)
        } else {
            // Immersive-to-window transition
            await openNewWindow(for: newMode, dismissingOld: oldMode)
        }
    }

    @MainActor private func transitionFromWindowMode(from oldMode: Mode, to newMode: Mode) async {
        if newMode.needsImmersiveSpace {
            await transitionToImmersiveSpace(from: oldMode, to: newMode)
        } else {
            // Window-to-window transition
            await openNewWindow(for: newMode, dismissingOld: oldMode)
        }
    }

    @MainActor private func transitionToImmersiveSpace(from oldMode: Mode, to newMode: Mode) async {
        print("Transitioning to immersive space")
        
        // Special case for immersive travel mode
        if newMode == .immersiveTravel {
            dismissWindow(id: ModeIDs.mainScreenWindowID)
        }
        
        // Open immersive space and button window
        immersiveSpacePresented = true
        await openImmersiveSpace(id: newMode.windowId)
        openWindow(id: ModeIDs.buttonWindowID)
        
        // Clean up old window after brief delay
        try! await Task.sleep(for: .milliseconds(50))
        dismissWindow(id: oldMode.windowId)
        
        print("Opened immersive space: \(newMode.windowId)")
    }

    @MainActor private func openNewWindow(for newMode: Mode, dismissingOld oldMode: Mode) async {
        guard !newMode.needsImmersiveSpace else { return }
        
        openWindow(id: newMode.windowId)
        print("Opened window: \(newMode.windowId)")
        
        if newMode.needsLastWindowClosed && !oldMode.needsImmersiveSpace {
            try! await Task.sleep(for: .milliseconds(50))
            dismissWindow(id: oldMode.windowId)
            print("Dismissed old window: \(oldMode.windowId)")
        }
    }

    @MainActor private func openNewImmersiveSpace(for newMode: Mode, dismissingOld oldMode: Mode) async {
        immersiveSpacePresented = true
        await openImmersiveSpace(id: newMode.windowId)
        openWindow(id: ModeIDs.buttonWindowID)
        
        print("Opened immersive space: \(newMode.windowId)")
    }
    
}
