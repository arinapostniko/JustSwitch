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
    }
    
    func openSystemPreferences() {
        accessibilityPermissionUseCase.openSystemPreferences()
    }
} 
