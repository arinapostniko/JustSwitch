//
//  WindowManager.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/2/25.
//

import SwiftUI
import AppKit

@MainActor
class WindowManager: ObservableObject {
    
    var window: NSWindow?
    let viewModel: WindowSwitcherViewModel
    
    init(viewModel: WindowSwitcherViewModel) {
        self.viewModel = viewModel
    }
    
    func show() {
        if window == nil {
            createWindow()
        }
        
        viewModel.show()
        NSApp.activate(ignoringOtherApps: true)
        window?.orderFront(nil)
        window?.makeKey()
    }
    
    func hide() {
        window?.orderOut(nil)
        window?.resignKey()
        viewModel.hide()
    }
    
    private func createWindow() {
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 510, height: 400),
                          styleMask: [.titled, .closable, .miniaturizable],
                          backing: .buffered,
                          defer: false)
        window?.level = .modalPanel
        window?.backgroundColor = NSColor.controlBackgroundColor
        window?.isOpaque = true
        window?.hasShadow = true
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .hidden
        window?.standardWindowButton(.closeButton)?.isHidden = true
        window?.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window?.standardWindowButton(.zoomButton)?.isHidden = true
        
        let hostingView = NSHostingView(rootView: WindowSwitcherView(viewModel: viewModel))
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
