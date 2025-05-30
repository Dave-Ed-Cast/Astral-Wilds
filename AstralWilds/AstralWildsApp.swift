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
            WindowGroup(id: ModeIDs.welcomeWindowID) { WelcomeView() }
                .windowResizability(.contentSize)
                .defaultSize(width: 520, height: 450)
            
            WindowGroup(id: ModeIDs.mainScreenWindowID) {
                MainView()
                    .opacity(chooseTimeWindowIsOpen ? 0.35 : 1)
                    .animation(.default, value: chooseTimeWindowIsOpen)
            }
            .windowResizability(.contentSize)
            .defaultSize(width: 700, height: 550)
            
            WindowGroup(id: ModeIDs.chooseTimeWindowID) {
                ChooseTimeView(durationSelection: $duration, sitting: $sitting)
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
                ImmersiveSpace(id: ModeIDs.planetImmersiveID) { MovingPlanets() }
                ImmersiveSpace(id: ModeIDs.choosePlanetsImmersiveID) { MovePlanetsYouChoose() }
                ImmersiveSpace(id: ModeIDs.immersiveTravelImmersiveId) { ImmersiveTravel(duration: $duration, sitting: $sitting) }
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
            await immersiveSpaceHandler(from: oldMode, to: newMode)
        } else {
            await windowsHandler(from: oldMode, to: newMode)
        }
    }

    /// Handles transitions when an immersive space is currently presented.
    /// Dismisses the existing immersive space and associated windows before proceeding.
    ///
    /// - Parameters:
    ///   - oldMode: The current mode being exited.
    ///   - newMode: The target mode being entered.
    @MainActor private func immersiveSpaceHandler(from oldMode: Mode, to newMode: Mode) async {
        dismissWindow(id: ModeIDs.buttonWindowID)
        await dismissImmersiveSpace()
        immersiveSpacePresented = false
        
        await openNewWindow(for: newMode, dismissingOld: oldMode)
    }

    /// Handles transitions when in windowed mode.
    /// Decides whether to enter an immersive space or simply switch windows.
    ///
    /// - Parameters:
    ///   - oldMode: The current mode being exited.
    ///   - newMode: The target mode being entered.
    @MainActor private func windowsHandler(from oldMode: Mode, to newMode: Mode) async {
        if newMode.needsImmersiveSpace {
            await transitionToImmersiveSpace(from: oldMode, to: newMode)
        } else {
            await openNewWindow(for: newMode, dismissingOld: oldMode)
        }
    }

    /// Transitions from windowed mode to an immersive space.
    /// Handles setup, delays, and window dismissal in sequence to avoid race conditions.
    ///
    /// - Parameters:
    ///   - oldMode: The current windowed mode.
    ///   - newMode: The immersive mode being entered.
    @MainActor private func transitionToImmersiveSpace(from oldMode: Mode, to newMode: Mode) async {
        print("Transitioning to immersive space")
        
        if newMode == .immersiveTravel {
            dismissWindow(id: ModeIDs.mainScreenWindowID)
        }
        
        immersiveSpacePresented = true
        await openImmersiveSpace(id: newMode.windowId)
        openWindow(id: ModeIDs.buttonWindowID)
        
        try! await Task.sleep(for: .milliseconds(50)) // Prevent race conditions
        dismissWindow(id: oldMode.windowId)
        
        print("Opened immersive space: \(newMode.windowId)")
    }

    /// Opens a new window based on the new mode and optionally dismisses the old one.
    /// Handles brief pauses to ensure safe transitions.
    ///
    /// - Parameters:
    ///   - newMode: The mode whose window should be opened.
    ///   - oldMode: The previous mode whose window may need to be closed.
    @MainActor private func openNewWindow(for newMode: Mode, dismissingOld oldMode: Mode) async {
        guard !newMode.needsImmersiveSpace else { return }
        
        openWindow(id: newMode.windowId)
        print("Opened window: \(newMode.windowId)")
        
        if newMode.needsLastWindowClosed && !oldMode.needsImmersiveSpace {
            try! await Task.sleep(for: .milliseconds(50)) // Prevent race conditions
            dismissWindow(id: oldMode.windowId)
            print("Dismissed old window: \(oldMode.windowId)")
        }
    }
    
    /// Opens an immersive space and a companion window (e.g., a control button).
    ///
    /// - Parameters:
    ///   - newMode: The mode whose immersive space should be opened.
    ///   - oldMode: The previous mode, used for potential dismissal.
    @MainActor private func openImmersiveSpace(for newMode: Mode, dismissingOld oldMode: Mode) async {
        immersiveSpacePresented = true
        await openImmersiveSpace(id: newMode.windowId)
        openWindow(id: ModeIDs.buttonWindowID)
        print("Opened immersive space: \(newMode.windowId)")
    }
    
}
