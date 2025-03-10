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
    
    @State private var mode: Mode = .welcome
    @State private var immersionMode: ImmersionStyle = .progressive(0...100.0, initialAmount: 100.0)
    @State private var duration: Int = 0
    
    @State private var sitting: Bool = true
    @State private var immersiveSpacePresented: Bool = false
    @State private var chooseTimeIsPresent: Bool = false
    @State private var gestureModel = GestureModel()
    
    // Usually, I put environment variables first; but due to immersionMode dependencies they must go here or Xcode complains.
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    private static let welcomeWindowID: String = "Welcome"
    private static let mainScreenWindowID: String = "Main"
    private static let buttonWindowID: String = "ImmersiveButton"
    private static let planetsWindowID: String = "MovingPlanets"
    private static let choosePlanetsWindowID: String = "ChoosePlanets"
    private static let chooseTimeWindowID: String = "TimeWindow"
    private static let immersiveTravelWindowId: String = "ImmersiveTravel"
    
    /// Represents the different states of the application.
    /// Each mode corresponds to a specific window ID and determines whether an immersive space is needed.
    @MainActor enum Mode: Equatable {
        case welcome, mainScreen, movingPlanets, chooseTime, choosePlanetsToMove, immersiveTravel
        
        /// Indicates if the mode requires an immersive space.
        fileprivate var needsImmersiveSpace: Bool {
            return self != .mainScreen && self != .chooseTime && self != .welcome
        }
        
        /// Indicates if the window should be closed when switching to this mode
        /// This variable must be accessed through mode, check `setMode` for examples
        fileprivate var needsLastWindowClosed: Bool {
            return self == .mainScreen
        }
        
        /// Returns the associated window identifier for the mode.
        fileprivate var windowId: String {
            switch self {
            case .welcome: return welcomeWindowID
            case .mainScreen: return mainScreenWindowID
            case .movingPlanets: return planetsWindowID
            case .chooseTime: return chooseTimeWindowID
            case .choosePlanetsToMove: return choosePlanetsWindowID
            case .immersiveTravel: return immersiveTravelWindowId
            }
        }
    }
    
    /// Initializes the AstralWilds app by registering the RealityKit gesture component.
    init() {
        RealityKitContent.GestureComponent.registerComponent()
    }
    
    var body: some Scene {
        Group {
            WindowGroup(id: Self.welcomeWindowID) {
                WelcomeView()
            }
            .windowResizability(.contentSize)
            .defaultSize(width: 520, height: 450)
            
            WindowGroup(id: Self.mainScreenWindowID) {
                MainView()
                    .opacity(chooseTimeIsPresent ? 0.35 : 1)
                    .animation(.default, value: chooseTimeIsPresent)
            }
            .windowResizability(.contentSize)
            .defaultSize(width: 700, height: 550)
            
            WindowGroup(id: Self.chooseTimeWindowID) {
                ChooseTimeView(duration: $duration, sitting: $sitting)
                    .onAppear { chooseTimeIsPresent = true }
                    .onDisappear { chooseTimeIsPresent = false }
            }
            .windowResizability(.contentSize)
            .defaultWindowPlacement { content, _ in
                WindowPlacement(
                    .utilityPanel,
                    size: content.sizeThatFits(.unspecified)
                )
            }
            
            WindowGroup(id: Self.buttonWindowID) {
#if targetEnvironment(simulator)
                ExitImmersiveSpaceButton()
#elseif !targetEnvironment(simulator)
                ExitImmersiveSpaceGesture()
                    .frame(width: 350, height: 180)
                    .background(.black.opacity(0.4))
#endif
            }
            .persistentSystemOverlays(.hidden)
            .windowResizability(.contentSize)
            .defaultWindowPlacement { content, context in
                let size = content.sizeThatFits(.unspecified)
                if let mainViewWindow = context.windows.first(where: { $0.id == Self.mainScreenWindowID }) {
                    return WindowPlacement(.below(mainViewWindow), size: size)
                } else if let chooseTimeWindow = context.windows.first(where: { $0.id == Self.chooseTimeWindowID }) {
                    return WindowPlacement(.replacing(chooseTimeWindow), size: size)
                }
                return WindowPlacement(.none)
            }
            
            Group {
                ImmersiveSpace(id: Self.planetsWindowID) { MovingPlanets() }
                ImmersiveSpace(id: Self.choosePlanetsWindowID) { MovePlanetsYouChoose() }
                ImmersiveSpace(id: Self.immersiveTravelWindowId) {
                    ImmersiveTravel(duration: $duration, sitting: $sitting)
                }
            }
            .environment(gestureModel)
            .immersionStyle(selection: $immersionMode, in: .mixed, .progressive, .full)
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
    /// Whenever an immersive space must be closed, the flow must can be whatever.
    /// ```
    /// - Parameter newMode: The new mode to transition to.
    @MainActor private func setMode(_ newMode: Mode) async {
        
        let oldMode = mode
        guard newMode != oldMode else { return }
        mode = newMode
        
        print("")
        print("oldMode: \(oldMode), newMode: \(newMode)")
        
        if immersiveSpacePresented {
            print("immersive -> window operation")
            dismissWindow(id: Self.buttonWindowID)
            print("dismissing button window")
            
            await dismissImmersiveSpace()
            immersiveSpacePresented = false
            print("dismissing immersive space")
        }
        
        if newMode.needsLastWindowClosed && !immersiveSpacePresented {
            print("new window operation")
            openWindow(id: newMode.windowId)
            print("opening: \(newMode.windowId)")
            do {
                try await Task.sleep(for: .seconds(0.05))
            } catch {
                print(error.localizedDescription)
            }
            if !oldMode.needsImmersiveSpace{
                dismissWindow(id: oldMode.windowId)
            }
        } else if !newMode.needsImmersiveSpace {
            print("new window that doesn't need immersive space")
            openWindow(id: newMode.windowId)
            print("opening: \(newMode.windowId)")
        }
        
        if newMode.needsImmersiveSpace {
            print("window(s) -> immersive")
            if newMode == .immersiveTravel {
                dismissWindow(id: Self.mainScreenWindowID)
                print("dismissed the main screen")
            }
            immersiveSpacePresented = true
            await openImmersiveSpace(id: newMode.windowId)
            print("opened the immersive space: \(newMode.windowId)")
            
            openWindow(id: Self.buttonWindowID)
            print("opened the button window")
            do {
                try await Task.sleep(for: .seconds(0.05))
            } catch {
                print(error.localizedDescription)
            }
            dismissWindow(id: oldMode.windowId)
            print("dismissed old window: \(oldMode.windowId)")
        }
    }
}
