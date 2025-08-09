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
            
            return Application(name: app.localizedName ?? "Unknown",
                              bundleIdentifier: bundleId,
                              icon: app.icon,
                              processIdentifier: app.processIdentifier)
        }
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
