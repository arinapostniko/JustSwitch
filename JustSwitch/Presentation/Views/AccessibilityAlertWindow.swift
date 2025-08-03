//
//  AccessibilityAlertWindow.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/2/25.
//

import SwiftUI
import AppKit

@MainActor
class AccessibilityAlertWindow: ObservableObject {
    
    var window: NSWindow?
    private let viewModel: AccessibilityViewModel
    
    init(viewModel: AccessibilityViewModel) {
        self.viewModel = viewModel
    }
    
    func show() {
        if window == nil {
            createWindow()
        }
        
        window?.orderFront(nil)
        window?.makeKey()
    }
    
    func hide() {
        window?.orderOut(nil)
    }
    
    private func createWindow() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        window?.title = "Accessibility Permissions"
        window?.level = .modalPanel
        window?.backgroundColor = NSColor.controlBackgroundColor
        
        let hostingView = NSHostingView(rootView: AccessibilityAlertView(viewModel: viewModel))
        window?.contentView = hostingView
        
        if let screen = NSScreen.main {
            let screenFrame = screen.frame
            let windowFrame = window?.frame ?? NSRect.zero
            let x = screenFrame.midX - windowFrame.width / 2
            let y = screenFrame.midY - windowFrame.height / 2
            window?.setFrameOrigin(NSPoint(x: x, y: y))
        }
    }
} 
