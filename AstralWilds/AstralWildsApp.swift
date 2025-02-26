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
    
    @State private var mode: Mode = .welcome
    @State private var immersionMode: ImmersionStyle = .progressive(0...100.0, initialAmount: 100.0)
    @State private var selectedDuration: Int = 0
    
    @State private var sitting: Bool = true
    @State private var immersiveSpacePresented: Bool = false
    @State private var chooseTimeIsPresent: Bool = false
    
    @State private var gestureModel = GestureModel()
    
    //Usually, I put environment first, but with immersionMode I must put them here or Xcode complains
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    
    private static let welcomeWindowID: String = "Welcome"
    private static let mainScreenWindowID: String = "Main"
    private static let tutorialWindowID: String = "Tutorial"
    private static let buttonWindowID: String = "ImmersiveButton"
    private static let planetsWindowID: String = "MovingPlanets"
    private static let choosePlanetsWindowID: String = "ChoosePlanets"
    private static let chooseTimeWindowID: String = "TimeWindow"
    private static let immersiveTravelWindowId: String = "ImmersiveTravel"
    
    /// This `Mode`defines the cases in which the app can be. They are window IDs.
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
    
    init() {
        RealityKitContent.GestureComponent
            .registerComponent()
    }
    
    var body: some Scene {
        
        Group {
            WindowGroup(id: Self.welcomeWindowID) {
                WelcomeView()
                    .background(.black.opacity(0.4))
                    .frame(
                        minWidth: 520, maxWidth: 1000,
                        minHeight: 450, maxHeight: 930
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
                    .background(.black.opacity(0.4))
                    .fixedSize()
                    .opacity(chooseTimeIsPresent ? 0.2 : 1)
            }
            .windowResizability(.contentSize)
            .defaultSize(width: 700, height: 550)
            
            WindowGroup(id: Self.tutorialWindowID) {
                TutorialView()
                    .background(.black.opacity(0.4)).ignoresSafeArea(.all)
                    .fixedSize()
                    .environment(\.setMode, setMode)
            }
            .defaultSize(width: 320, height: 200)
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
            .defaultWindowPlacement { content, context in
                
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
#elseif !targetEnvironment(simulator)
                    ExitImmersiveSpaceGesture()
#endif
                }
                .fixedSize()
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
            
            Group {
                ImmersiveSpace(id: Self.planetsWindowID) {
                    MovingPlanets()
                    
                }
                
                ImmersiveSpace(id: Self.choosePlanetsWindowID) {
                    MovePlanetsYouChoose()
                    
                }
                
                ImmersiveSpace(id: Self.immersiveTravelWindowId) {
                    ImmersiveTravel(duration: $selectedDuration, sitting: $sitting)
                }
            }
            .environment(gestureModel)
            .immersionStyle(selection: $immersionMode, in: .mixed, .progressive, .full)
        }
                .environment(\.setMode, setMode)
    }
    
    /// This handles the opening and dismissing of either windows and immersive spaces
    /// - Parameter newMode: is the next mode after interacting within the app
    @MainActor private func setMode(_ newMode: Mode) async {
        
        let oldMode = mode
        guard newMode != oldMode else { return }
        mode = newMode
        
        if immersiveSpacePresented {
            
            immersiveSpacePresented = false
            openWindow(id: newMode.windowId)
            try? await Task.sleep(for: .seconds(0.01))
            dismissWindow(id: Self.buttonWindowID)
            await dismissImmersiveSpace()
            
            
        } else if newMode.needsLastWindowClosed {
            openWindow(id: newMode.windowId)
            try? await Task.sleep(for: .seconds(0.01))
            dismissWindow(id: oldMode.windowId)
        }
        
        if newMode.needsImmersiveSpace {
            
            dismissWindow(id: oldMode.windowId)

            if newMode == .immersiveTravel {
                dismissWindow(id: Self.mainScreenWindowID)
            }
            immersiveSpacePresented = true
            await openImmersiveSpace(id: newMode.windowId)
            
            //Need the button to appear with the immersive space
            openWindow(id: Self.buttonWindowID)
            try? await Task.sleep(for: .seconds(0.1))
        }
    }
}
