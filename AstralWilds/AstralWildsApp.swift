//
//  AstralWildsApp.swift
//  AstralWilds
//
//  Created by Davide Castaldi on 12/05/24.
//

import SwiftUI
import RealityKitContent

/// Here we have the different windows alongside a function working on the `MainActor` to handle UI changes.
@main
struct AstralWildsApp: App {
    
    /// This initializes all the gestures that can be used
    init() {
        RealityKitContent.GestureComponent
            .registerComponent()
    }
    
    private static let welcomeWindowID: String = "Welcome"
    private static let mainScreenWindowID: String = "Main"
    private static let tutorialWindowID: String = "Tutorial"
    private static let buttonWindowID: String = "ImmersiveButton"
    private static let planetsWindowID: String = "MovingPlanets"
    private static let choosePlanetsWindowID: String = "ChoosePlanets"
    private static let chooseTimeWindowID: String = "TimeWindow"
    private static let immersiveTravelWindowId: String = "ImmersiveTravel"
    
    /// This "Mode" defines the cases in which the app can be. They are window IDs.
    /// There are also variables such as along with that defines which one should use an immersive space,
    /// and which windows to close that are not needed anymore.
    @MainActor enum Mode: Equatable {
        case welcome
        case mainScreen
        case movingPlanets
        case chooseTime
        case choosePlanetsToMove
        case immersiveTravel
        
        fileprivate var needsImmersiveSpace: Bool {
            return self != .mainScreen && self != .chooseTime && self != .welcome
        }
        
        fileprivate var needsLastWindowClosed: Bool {
            return self == .mainScreen || self == .chooseTime
        }
                
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
    
    @State private var mode: Mode = .welcome
    @State private var immersiveSpacePresented: Bool = false
    @State private var immersionMode: ImmersionStyle = .progressive(0...100, initialAmount: 100)
    @State private var duration: Int = 0
    @State private var sitting: Bool = true
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
        guard newMode != oldMode else { return }
        mode = newMode
                
        if immersiveSpacePresented {
            
            immersiveSpacePresented = false
            dismissWindow(id: Self.buttonWindowID)
            await dismissImmersiveSpace()
            openWindow(id: newMode.windowId)

        } else if newMode.needsLastWindowClosed {
            dismissWindow(id: oldMode.windowId)
            openWindow(id: newMode.windowId)
        }
        
        if newMode.needsImmersiveSpace {
            
            immersiveSpacePresented = true
            await openImmersiveSpace(id: newMode.windowId)
            
            //Need the button to appear with the immersive space
            openWindow(id: Self.buttonWindowID)
            dismissWindow(id: oldMode.windowId)
        }
    }
    
    /// Here are all the views and immersive spaces needed.
    ///
    /// The window group allows windows to be created that act as containers of views.
    /// This can be leveraged for UI overlay in Immersive spaces.
    var body: some Scene {
        
        WindowGroup(id: Self.welcomeWindowID) {
            
            WelcomeView()
                .environment(\.setMode, setMode)
                .background(.black.opacity(0.4))
            
                .frame(
                    minWidth: 520, maxWidth: 1000,
                    minHeight: 450, maxHeight: 930,
                    alignment: .center
                )
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 520, height: 450)
        
        WindowGroup(id: Self.mainScreenWindowID) {
            MainView()
                .frame(
                    minWidth: 700, maxWidth: 1000,
                    minHeight: 550, maxHeight: 900
                )
                .environment(\.setMode, setMode)
                .background(.black.opacity(0.4))
            //Until the adaptive UI is fixed
                .fixedSize()
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 700, height: 550)
        
        WindowGroup(id: Self.tutorialWindowID) {
            
            TutorialView()
                .frame(width: 320, height: 200)
                .background(.black.opacity(0.4)).ignoresSafeArea(.all)
                .fixedSize()
        }
        .windowResizability(.contentSize)
        .defaultWindowPlacement { content, context in
            
            let size = content.sizeThatFits(.unspecified)
            if let mainViewWindow = context.windows.first(where: { $0.id == Self.mainScreenWindowID }) {
                
                return WindowPlacement(
                    .trailing(mainViewWindow),
                    size: size
                )
            }
            return WindowPlacement(.none)
        }
        
        /// I guess there is a main actor issue or something.
        /// When i use `setMode` this should close the main view once this one appears, but it doesn't.
        WindowGroup(id: Self.chooseTimeWindowID) {
            BeforeImmersiveView(duration: $duration, sitting: $sitting)
                .fixedSize()
                .background(.black.opacity(0.4))
        }
        .environment(\.setMode, setMode)
        .windowResizability(.contentSize)
        .defaultWindowPlacement { content, context in
            
            dismissWindow(id: Self.mainScreenWindowID)
            return WindowPlacement(
                .utilityPanel,
                size: content.sizeThatFits(.unspecified)
            )
        }
        
        WindowGroup(id: Self.buttonWindowID) {
            ZStack {
                Color.black.opacity(0.4)
#if targetEnvironment(simulator)
                ExitImmersiveSpaceButton(mode: $mode)
                    .fixedSize()
                    .environment(\.setMode, setMode)
#elseif !targetEnvironment(simulator)
                ExitImmersiveSpaceGesture()
                    .fixedSize()
                    .environment(\.setMode, setMode)
#endif
            }
        }
        .windowResizability(.contentMinSize)
        .defaultWindowPlacement { content, context in
            
            let size = content.sizeThatFits(.unspecified)
            if let mainViewWindow = context.windows.first(where: { $0.id == Self.mainScreenWindowID }) {
                
                return WindowPlacement(
                    .below(mainViewWindow),
                    size: size
                )
            } else if let chooseTimeWindow = context.windows.first(where: { $0.id == Self.chooseTimeWindowID }) {
                
                return WindowPlacement(.replacing(chooseTimeWindow), size: size)
            }
            return WindowPlacement(.none)
        }
        
        ImmersiveSpace(id: Self.planetsWindowID) {
            MovingPlanets()
                .environment(gestureModel)
                .environment(\.setMode, setMode)
            
        }
        .immersionStyle(selection: $immersionMode, in: .mixed, .progressive, .full)
        
        ImmersiveSpace(id: Self.choosePlanetsWindowID) {
            withAnimation(.easeInOut) {
                MovePlanetsYouChoose()
                    .environment(gestureModel)
                    .environment(\.setMode, setMode)
            }
        }
        .immersionStyle(selection: $immersionMode, in: .mixed, .progressive, .full)
        
        ImmersiveSpace(id: Self.immersiveTravelWindowId) {
            withAnimation(.easeInOut) {
                ImmersiveTravel(duration: $duration, sitting: $sitting)
                    .environment(gestureModel)
                    .environment(\.setMode, setMode)
                    .onAppear {
                        dismissWindow(id: Self.mainScreenWindowID)
                    }
            }
        }
        .immersionStyle(selection: $immersionMode, in: .mixed, .progressive, .full)
    }
}
