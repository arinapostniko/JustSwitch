//
//  WindowSwitcherViewModel.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/2/25.
//

import SwiftUI
import Foundation

@MainActor
class WindowSwitcherViewModel: ObservableObject {
    
    @Published var isVisible = false
    @Published var applications: [Application] = []
    @Published var selectedIndex = 0
    
    private let windowSwitcherUseCase: WindowSwitcherUseCaseProtocol
    private var isOptionHeld = false
    private var optionReleaseTimer: Timer?
    private var refreshTimer: Timer?
    
    init(windowSwitcherUseCase: WindowSwitcherUseCaseProtocol) {
        self.windowSwitcherUseCase = windowSwitcherUseCase
        refreshApplications()
    }
    
    func show() {
        refreshApplications()
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
        
        isVisible = true
        startOptionReleaseTimer()
        startRefreshTimer()
    }
    
    func handleOptionTab() {
        if !isVisible {
            isOptionHeld = true
            show()
        }
    }
    
    private func startOptionReleaseTimer() {
        optionReleaseTimer?.invalidate()
        optionReleaseTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            Task { @MainActor in
                self.checkOptionRelease()
            }
        }
    }
    
    private func checkOptionRelease() {
        let currentModifiers = NSEvent.modifierFlags
        let optionHeld = currentModifiers.contains(.option)
        
        if !optionHeld && isVisible {
            optionReleaseTimer?.invalidate()
            optionReleaseTimer = nil
            activateSelected()
        }
    }
    
    private func startRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            Task { @MainActor in
                if self.isVisible {
                    self.refreshApplications()
                }
            }
        }
    }
    
    private func pauseRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    private func resumeRefreshTimer() {
        startRefreshTimer()
    }
    
    /// This is called when Tab is released, but the switcher window kept open
    /// until Option is released
    func handleOptionTabRelease() {
        print("handleOptionTabRelease called")
    }
    
    func hide() {
        isVisible = false
        optionReleaseTimer?.invalidate()
        optionReleaseTimer = nil
        refreshTimer?.invalidate()
        refreshTimer = nil
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func refreshApplications() {
        if applications.isEmpty {
            windowSwitcherUseCase.refreshApplications()
            applications = windowSwitcherUseCase.getApplications()
            selectedIndex = 0
            windowSwitcherUseCase.setSelectedIndex(0)
            return
        }
        
        if selectedIndex >= applications.count {
            selectedIndex = 0
            windowSwitcherUseCase.setSelectedIndex(0)
        }
        
        let currentSelectedApp = applications[selectedIndex]
        windowSwitcherUseCase.refreshApplications()
        applications = windowSwitcherUseCase.getApplications()
        
        if let newIndex = applications.firstIndex(where: { $0.id == currentSelectedApp.id }) {
            selectedIndex = newIndex
            windowSwitcherUseCase.setSelectedIndex(newIndex)
        }
    }
    
    func selectNext() {
        pauseRefreshTimer()
        windowSwitcherUseCase.selectNext()
        selectedIndex = windowSwitcherUseCase.getSelectedIndex()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.resumeRefreshTimer()
        }
    }
    
    func selectPrevious() {
        pauseRefreshTimer()
        windowSwitcherUseCase.selectPrevious()
        selectedIndex = windowSwitcherUseCase.getSelectedIndex()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.resumeRefreshTimer()
        }
    }
    
    func activateSelected() {
        guard selectedIndex < applications.count else { return }
        windowSwitcherUseCase.activateSelected()
        hide()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.hide()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if let appDelegate = globalAppDelegate {
                appDelegate.windowManager?.hide()
            }
        }
    }
    
    func setSelectedIndex(_ index: Int) {
        windowSwitcherUseCase.setSelectedIndex(index)
        selectedIndex = index
    }
    
    func setSelectedIndexWithoutActivating(_ index: Int) {
        windowSwitcherUseCase.setSelectedIndex(index)
        selectedIndex = index
    }
} 
