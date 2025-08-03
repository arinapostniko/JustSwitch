//
//  AccessibilityViewModel.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/2/25.
//

import SwiftUI
import Foundation

@MainActor
class AccessibilityViewModel: ObservableObject {
    
    @Published var isPermissionGranted = false
    @Published var showPermissionAlert = false
    @Published var permissionAlertMessage = ""
    
    private let accessibilityPermissionUseCase: AccessibilityPermissionUseCaseProtocol
    
    init(accessibilityPermissionUseCase: AccessibilityPermissionUseCaseProtocol) {
        self.accessibilityPermissionUseCase = accessibilityPermissionUseCase
        checkPermissionStatus()
    }
    
    func checkPermissionStatus() {
        isPermissionGranted = accessibilityPermissionUseCase.checkPermissionStatus()
    }
    
    func requestPermissions() {
        let granted = accessibilityPermissionUseCase.requestPermissions()
        isPermissionGranted = granted
        
        if !granted {
            showPermissionAlert = true
            permissionAlertMessage = "JustSwitch needs accessibility permissions to detect Option+Tab globally.\n\n1. Click 'Open Settings' to go to System Preferences\n2. Click the lock icon to make changes\n3. Add JustSwitch to the list and check it\n4. Restart the app"
        }
    }
    
    func openSystemPreferences() {
        accessibilityPermissionUseCase.openSystemPreferences()
    }
    
    func retryPermissionRequest() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.requestPermissions()
        }
    }
    
    func getSavedPermissionStatus() -> Bool {
        accessibilityPermissionUseCase.getSavedPermissionStatus()
    }
} 
