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
    
    /// Current mode of the app, which determines which window is active.
    @State private var mode: Mode = .welcome
    
    /// The immersive style used for immersive
    @State private var immersionMode: ImmersionStyle = .progressive(0...100.0, initialAmount: 100.0)
    
    /// Duration selected for immersive travel.
    @State private var selectedDuration: Int = 0
    
    /// Indicates whether the user is sitting.
    @State private var sitting: Bool = true
    
    /// Tracks if an immersive space is currently presented.
    @State private var immersiveSpacePresented: Bool = false
    
    /// Indicates whether the "Choose Time" window is visible.
    @State private var chooseTimeIsPresent: Bool = false
    
    /// Model used for handling gesture interactions within immersive spaces.
    @State private var gestureModel = GestureModel()
    
    // Normally, I place environment variables first; but due to immersionMode dependencies these must go here or Xcode complains.
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
    ///
    /// Each mode corresponds to a specific window ID and determines whether an immersive space is needed.
    @MainActor enum Mode: Equatable {
        case welcome
        case mainScreen
        case movingPlanets
        case chooseTime
        case choosePlanetsToMove
        case immersiveTravel
        
        /// Indicates if the mode requires an immersive space.
        fileprivate var needsImmersiveSpace: Bool {
            return self != .mainScreen && self != .chooseTime && self != .welcome
        }
        
        /// Indicates if the previous window should be closed when switching to this mode.
        fileprivate var needsLastWindowClosed: Bool {
            return self == .mainScreen || self == .chooseTime
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
    
    // MARK: - Scene Definition
    
    var body: some Scene {
        Group {
            WindowGroup(id: Self.welcomeWindowID) {
                WelcomeView()
                    .background(.black.opacity(0.4))
                    .frame(minWidth: 520, maxWidth: 1000,
                           minHeight: 450, maxHeight: 930)
            }
            .windowResizability(.contentSize)
            .defaultSize(width: 520, height: 450)
            
            WindowGroup(id: Self.mainScreenWindowID) {
                MainView()
                    .frame(minWidth: 700, maxWidth: 1000,
                           minHeight: 550, maxHeight: 900)
                    .background(.black.opacity(0.4))
                    .fixedSize()
                    .opacity(chooseTimeIsPresent ? 0.2 : 1)
            }
            .windowResizability(.contentSize)
            .defaultSize(width: 700, height: 550)
            
            WindowGroup(id: Self.chooseTimeWindowID) {
                ChooseTimeView(durationSelection: $selectedDuration, sitting: $sitting)
                    .fixedSize()
                    .background(.black.opacity(0.4))
                    .onAppear { chooseTimeIsPresent = true }
                    .onDisappear {
                        chooseTimeIsPresent = false
                        mode = .mainScreen
                    }
            }
            .windowResizability(.contentSize)
            .defaultWindowPlacement { content, _ in
                WindowPlacement(
                    .utilityPanel,
                    size: content.sizeThatFits(.unspecified)
                )
            }
            
            WindowGroup(id: Self.buttonWindowID) {
                ZStack {
                    Color.black.opacity(0.4)
#if targetEnvironment(simulator)
                    ExitImmersiveSpaceButton(mode: $mode)
#elseif !targetEnvironment(simulator)
                    ExitImmersiveSpaceGesture()
#endif
                }
                .fixedSize()
            }
            .persistentSystemOverlays(.hidden)
            .windowResizability(.contentMinSize)
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
                // Moving Planets Immersive Space
                ImmersiveSpace(id: Self.planetsWindowID) {
                    MovingPlanets()
                }
                
                // Choose Planets Immersive Space
                ImmersiveSpace(id: Self.choosePlanetsWindowID) {
                    MovePlanetsYouChoose()
                }
                
                // Immersive Travel Immersive Space
                ImmersiveSpace(id: Self.immersiveTravelWindowId) {
                    ImmersiveTravel(duration: $selectedDuration, sitting: $sitting)
                }
            }
            .environment(gestureModel)
            .immersionStyle(selection: $immersionMode, in: .mixed, .progressive, .full)
        }
        .environment(\.setMode, setMode)
    }
    
    
    /// Handles transitions between different modes by opening and dismissing windows and immersive spaces.
    ///
    /// Each transition includes a short sleep to mitigate potential race conditions and concurrency issues on visionOS.
    /// - Parameter newMode: The new mode to transition to.
    @MainActor private func setMode(_ newMode: Mode) async {
        
        let oldMode = mode
        //No transition if the mode hasn't changed.
        guard newMode != oldMode else { return }
        mode = newMode
        
        if immersiveSpacePresented {
            //Close the space -> dismiss the window and open main.
            immersiveSpacePresented = false
            await dismissImmersiveSpace()
            dismissWindow(id: Self.buttonWindowID)
            try? await Task.sleep(for: .seconds(0.01))
            openWindow(id: newMode.windowId)
            
        } else if newMode.needsLastWindowClosed {
            // Transition by opening the new window and dismissing the previous one.
            openWindow(id: newMode.windowId)
            try? await Task.sleep(for: .seconds(0.01))
            dismissWindow(id: oldMode.windowId)
        }
        
        if newMode.needsImmersiveSpace {
            // If a space is required, dismiss the old window
            dismissWindow(id: oldMode.windowId)
            
            // Special handling for immersive travel mode.
            if newMode == .immersiveTravel {
                dismissWindow(id: Self.mainScreenWindowID)
            }
            immersiveSpacePresented = true
            await openImmersiveSpace(id: newMode.windowId)
            
            try? await Task.sleep(for: .seconds(0.01))
            // Open the immersive exit button.
            openWindow(id: Self.buttonWindowID)
            
        }
    }
}
