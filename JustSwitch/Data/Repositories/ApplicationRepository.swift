//
//  ApplicationRepository.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/2/25.
//

import AppKit
import Foundation

class ApplicationRepository: ApplicationRepositoryProtocol {
    
    func getRunningApplications() -> [Application] {
        let workspace = NSWorkspace.shared
        let runningApps = workspace.runningApplications.filter { app in
            return app.activationPolicy == .regular && 
                   app.bundleIdentifier != Bundle.main.bundleIdentifier &&
                   !app.isTerminated &&
                   app.bundleIdentifier != nil &&
                   !app.bundleIdentifier!.isEmpty
        }
        
        return runningApps.compactMap { app in
            guard let bundleId = app.bundleIdentifier,
                  !bundleId.isEmpty else { return nil }
            
            let windowTitle = getWindowTitle(for: app.processIdentifier)
            
            return Application(name: app.localizedName ?? "Unknown",
                              bundleIdentifier: bundleId,
                              icon: app.icon,
                              processIdentifier: app.processIdentifier,
                              windowTitle: windowTitle)
        }
    }
    
    private func getWindowTitle(for processIdentifier: pid_t) -> String? {
        let app = AXUIElementCreateApplication(processIdentifier)
        
        var windowsRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(app, kAXWindowsAttribute as CFString, &windowsRef)
        
        guard result == .success,
              let windows = windowsRef as? [AXUIElement],
              let firstWindow = windows.first else {
            return nil
        }
        
        var titleRef: CFTypeRef?
        let titleResult = AXUIElementCopyAttributeValue(firstWindow, kAXTitleAttribute as CFString, &titleRef)
        
        guard titleResult == .success,
              let title = titleRef as? String,
              !title.isEmpty else {
            return nil
        }
        
        return title
    }
    
    func activateApplication(_ application: Application) {
        let workspace = NSWorkspace.shared
        let runningApps = workspace.runningApplications
        
        if let targetApp = runningApps.first(where: { $0.bundleIdentifier == application.bundleIdentifier }) {
            if targetApp.isHidden {
                targetApp.unhide()
            }
            
            targetApp.activate(options: .activateIgnoringOtherApps)
            
            if targetApp.activationPolicy == .regular {
                if let appURL = workspace.urlForApplication(withBundleIdentifier: application.bundleIdentifier) {
                    workspace.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration())
                } else {
                    print("Could not find app URL")
                }
            }
        } else {
            if let appURL = workspace.urlForApplication(withBundleIdentifier: application.bundleIdentifier) {
                workspace.openApplication(at: appURL, configuration: NSWorkspace.OpenConfiguration())
            } else {
                print("Could not find app URL for launch")
            }
        }
    }
} 
