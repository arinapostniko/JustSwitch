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
        ApplicationRepository()
    }()
    
    // MARK: Use Cases
    lazy var getRunningApplicationsUseCase: GetRunningApplicationsUseCaseProtocol = {
        GetRunningApplicationsUseCase(applicationRepository: applicationRepository)
    }()
    lazy var activateApplicationUseCase: ActivateApplicationUseCaseProtocol = {
        ActivateApplicationUseCase(applicationRepository: applicationRepository)
    }()
    lazy var windowSwitcherUseCase: WindowSwitcherUseCaseProtocol = {
        WindowSwitcherUseCase(getRunningApplicationsUseCase: getRunningApplicationsUseCase,
                                     activateApplicationUseCase: activateApplicationUseCase)
    }()
    lazy var accessibilityPermissionUseCase: AccessibilityPermissionUseCaseProtocol = {
        AccessibilityPermissionUseCase()
    }()
    
    // MARK: View Models
    @MainActor
    func makeWindowSwitcherViewModel() -> WindowSwitcherViewModel {
        WindowSwitcherViewModel(windowSwitcherUseCase: windowSwitcherUseCase)
    }
    @MainActor
    func makeAccessibilityViewModel() -> AccessibilityViewModel {
        AccessibilityViewModel(accessibilityPermissionUseCase: accessibilityPermissionUseCase)
    }
    
    // MARK: Window Manager
    @MainActor
    func makeWindowManager(viewModel: WindowSwitcherViewModel) -> WindowManager {
        WindowManager(viewModel: viewModel)
    }
} 
