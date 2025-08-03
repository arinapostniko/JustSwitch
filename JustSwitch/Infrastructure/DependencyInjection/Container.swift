//
//  Container.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/2/25.
//

import Foundation

class Container {
    
    static let shared = Container()
    
    private init() {}
    
    // MARK: Repositories
    lazy var applicationRepository: ApplicationRepositoryProtocol = {
        return ApplicationRepository()
    }()
    
    // MARK: Use Cases
    lazy var getRunningApplicationsUseCase: GetRunningApplicationsUseCaseProtocol = {
        return GetRunningApplicationsUseCase(applicationRepository: applicationRepository)
    }()
    
    lazy var activateApplicationUseCase: ActivateApplicationUseCaseProtocol = {
        return ActivateApplicationUseCase(applicationRepository: applicationRepository)
    }()
    
    lazy var windowSwitcherUseCase: WindowSwitcherUseCaseProtocol = {
        return WindowSwitcherUseCase(getRunningApplicationsUseCase: getRunningApplicationsUseCase,
                                     activateApplicationUseCase: activateApplicationUseCase)
    }()
    
    lazy var accessibilityPermissionUseCase: AccessibilityPermissionUseCaseProtocol = {
        return AccessibilityPermissionUseCase()
    }()
    
    // MARK: View Models
    @MainActor
    func makeWindowSwitcherViewModel() -> WindowSwitcherViewModel {
        return WindowSwitcherViewModel(windowSwitcherUseCase: windowSwitcherUseCase)
    }
    
    @MainActor
    func makeAccessibilityViewModel() -> AccessibilityViewModel {
        return AccessibilityViewModel(accessibilityPermissionUseCase: accessibilityPermissionUseCase)
    }
    
    // MARK: Window Manager
    @MainActor
    func makeWindowManager(viewModel: WindowSwitcherViewModel) -> WindowManager {
        return WindowManager(viewModel: viewModel)
    }
    
    @MainActor
    func makeAccessibilityAlertWindow(viewModel: AccessibilityViewModel) -> AccessibilityAlertWindow {
        return AccessibilityAlertWindow(viewModel: viewModel)
    }
} 
