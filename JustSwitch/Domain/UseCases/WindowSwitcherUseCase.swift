//
//  WindowSwitcherUseCase.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/2/25.
//

import Foundation

protocol WindowSwitcherUseCaseProtocol {
    func getApplications() -> [Application]
    func selectNext()
    func selectPrevious()
    func activateSelected()
    func getSelectedIndex() -> Int
    func setSelectedIndex(_ index: Int)
    func refreshApplications()
}

class WindowSwitcherUseCase: WindowSwitcherUseCaseProtocol {
    
    private let getRunningApplicationsUseCase: GetRunningApplicationsUseCaseProtocol
    private let activateApplicationUseCase: ActivateApplicationUseCaseProtocol
    
    private var applications: [Application] = []
    private var selectedIndex: Int = 0
    
    init(getRunningApplicationsUseCase: GetRunningApplicationsUseCaseProtocol,
         activateApplicationUseCase: ActivateApplicationUseCaseProtocol) {
        self.getRunningApplicationsUseCase = getRunningApplicationsUseCase
        self.activateApplicationUseCase = activateApplicationUseCase
        refreshApplications()
    }
    
    func getApplications() -> [Application] {
        return applications
    }
    
    func selectNext() {
        if !applications.isEmpty {
            selectedIndex = (selectedIndex + 1) % applications.count
        } else {
            print("WindowSwitcherUseCase.selectNext: no applications available")
        }
    }
    
    func selectPrevious() {
        if !applications.isEmpty {
            selectedIndex = selectedIndex == 0 ? applications.count - 1 : selectedIndex - 1
        }
    }
    
    func activateSelected() {
        guard selectedIndex < applications.count else { return }
        let app = applications[selectedIndex]
        activateApplicationUseCase.execute(application: app)
    }
    
    func getSelectedIndex() -> Int {
        selectedIndex
    }
    
    func setSelectedIndex(_ index: Int) {
        selectedIndex = index
    }
    
    func refreshApplications() {
        let newApplications = getRunningApplicationsUseCase.execute()
        let currentBundleIds = Set(applications.map { $0.bundleIdentifier })
        let newBundleIds = Set(newApplications.map { $0.bundleIdentifier })
        
        if newApplications.count != applications.count || currentBundleIds != newBundleIds {
            let currentlySelectedApp = selectedIndex < applications.count ? applications[selectedIndex] : nil
            
            applications = newApplications
            
            if let selectedApp = currentlySelectedApp,
               let newIndex = applications.firstIndex(where: { $0.bundleIdentifier == selectedApp.bundleIdentifier }) {
                selectedIndex = newIndex
            } else {
                selectedIndex = applications.isEmpty ? 0 : min(selectedIndex, applications.count - 1)
            }
        }
    }
} 
