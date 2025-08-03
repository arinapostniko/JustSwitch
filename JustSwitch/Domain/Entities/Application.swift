//
//  Application.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/2/25.
//

import AppKit

struct Application: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
    let icon: NSImage?
    let processIdentifier: pid_t
    
    static func == (lhs: Application, rhs: Application) -> Bool {
        return lhs.bundleIdentifier == rhs.bundleIdentifier
    }
} 
