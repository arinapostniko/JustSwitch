//
//  AccessibilityPermissionUseCase.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/2/25.
//

import Foundation
import AppKit

protocol AccessibilityPermissionUseCaseProtocol {
    func checkPermissionStatus() -> Bool
    func requestPermissions() -> Bool
    func openSystemPreferences()
    func savePermissionStatus(_ granted: Bool)
    func getSavedPermissionStatus() -> Bool
}

class AccessibilityPermissionUseCase: AccessibilityPermissionUseCaseProtocol {
    
    private let userDefaults = UserDefaults.standard
    private let permissionKey = "JustSwitch_AccessibilityPermission"
    
    func checkPermissionStatus() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    func requestPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        savePermissionStatus(trusted)
        
        return trusted
    }
    
    func openSystemPreferences() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        } else {
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Security.prefPane"))
        }
    }
    
    func savePermissionStatus(_ granted: Bool) {
        userDefaults.set(granted, forKey: permissionKey)
    }
    
    func getSavedPermissionStatus() -> Bool {
        return userDefaults.bool(forKey: permissionKey)
    }
} 
