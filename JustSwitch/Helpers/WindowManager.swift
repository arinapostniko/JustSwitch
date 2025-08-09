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
    private var localEventMonitor: Any?
    private var globalEventMonitor: Any?
    
    init(viewModel: WindowSwitcherViewModel) {
        self.viewModel = viewModel
    }
    
    func show() {
        if window == nil {
            createWindow()
        }
        
        viewModel.show()
        setupKeyboardHandling()
        
        DispatchQueue.main.async { [weak self] in
            self?.centerWindow()
        }
        
        NSApp.activate(ignoringOtherApps: true)
        window?.orderFront(nil)
        window?.makeKeyAndOrderFront(nil)
        
        DispatchQueue.main.async { [weak self] in
            self?.window?.makeFirstResponder(self?.window?.contentView)
        }
    }
    
    func hide() {
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }
        
        if let monitor = globalEventMonitor {
            NSEvent.removeMonitor(monitor)
            globalEventMonitor = nil
        }
        
        window?.orderOut(nil)
        window?.resignKey()
        viewModel.hide()
    }
    
    private func createWindow() {
        window = KeyableWindow(contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                               styleMask: [.borderless],
                               backing: .buffered,
                               defer: false)
        window?.level = .modalPanel
        window?.backgroundColor = NSColor.clear
        window?.isOpaque = false
        window?.hasShadow = false
        window?.titlebarAppearsTransparent = true
        window?.titleVisibility = .hidden
        window?.acceptsMouseMovedEvents = true
        
        let hostingView = NSHostingView(rootView: WindowSwitcherView(viewModel: viewModel))
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        window?.contentView = hostingView
        window?.contentView?.needsLayout = true
        
        centerWindow()
    }
    
    private func centerWindow() {
        guard let window = window, let screen = NSScreen.main else { return }
        
        window.contentView?.layoutSubtreeIfNeeded()
        
        let screenFrame = screen.visibleFrame
        let maxHeight = screenFrame.height * 0.8
        
        let contentSize = window.contentView?.fittingSize ?? NSSize(width: 300, height: 200)
        let windowHeight = min(contentSize.height, maxHeight)
        let windowWidth = max(contentSize.width, 300)
        
        let x = screenFrame.midX - windowWidth / 2
        let y = screenFrame.midY - windowHeight / 2
        
        window.setFrame(NSRect(x: x, y: y, width: windowWidth, height: windowHeight), display: true)
    }
    
    private func setupKeyboardHandling() {
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }
        
        if let monitor = globalEventMonitor {
            NSEvent.removeMonitor(monitor)
            globalEventMonitor = nil
        }
        
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.handleKeyEvent(event)
        }
        
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
            self?.handleKeyEvent(event)
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        switch event.keyCode {
        case 48: /// Tab key
            if event.modifierFlags.contains(.option) {
                DispatchQueue.main.async { [weak self] in
                    self?.viewModel.selectNext()
                }
                return nil
            }
            return event
        case 125: /// Down arrow
            DispatchQueue.main.async { [weak self] in
                self?.viewModel.selectNext()
            }
            return nil
        case 126: /// Up arrow
            DispatchQueue.main.async { [weak self] in
                self?.viewModel.selectPrevious()
            }
            return nil
        case 53: /// Escape
            DispatchQueue.main.async { [weak self] in
                self?.hide()
            }
            return nil
        case 49: /// Space bar - for testing
            DispatchQueue.main.async { [weak self] in
                self?.viewModel.activateSelected()
            }
            return nil
        case 36: /// Return/Enter key
            DispatchQueue.main.async { [weak self] in
                self?.hide()
            }
            return nil
        default:
            return event
        }
    }
} 
