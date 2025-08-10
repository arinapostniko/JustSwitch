//
//  AppDelegate.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/3/25.
//

import AppKit
import Carbon

/// Global reference to the app delegate for Carbon event handlers
/// This is needed because Carbon event handlers cannot capture context
var globalAppDelegate: AppDelegate?

/// Main application delegate that handles menu bar setup, global hotkeys, and accessibility permissions
class AppDelegate: NSObject, NSApplicationDelegate {
    
    /// Status item in the menu bar
    var statusItem: NSStatusItem?
    
    /// Window manager instance that manages the app switching interface
    var windowManager: WindowManager?
    
    /// Accessibility view model for permission management
    var accessibilityViewModel: AccessibilityViewModel?
    
    /// Carbon event monitors for global hotkey detection
    var globalMonitor: Any?
    var globalUpMonitor: Any?
    var localMonitor: Any?
    
    /// Carbon hotkey reference
    var hotKeyRef: EventHotKeyRef?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        globalAppDelegate = self
        setupMenuBar()
        
        Task { @MainActor in
            setupWindowManager()
            setupAccessibilityViewModel()
            requestAccessibilityPermissions()
        }
    }
    
    private func setupMenuBar() {
        NSApp.setActivationPolicy(.accessory)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "macwindow.on.rectangle", accessibilityDescription: "JustSwitch")
            button.imagePosition = .imageLeft
        }
        
        setupMenu()
    }
    
    @MainActor
    private func setupWindowManager() {
        let viewModel = Container.shared.makeWindowSwitcherViewModel()
        windowManager = Container.shared.makeWindowManager(viewModel: viewModel)
    }
    
    @MainActor
    private func setupAccessibilityViewModel() {
        accessibilityViewModel = Container.shared.makeAccessibilityViewModel()
    }
    
    private func requestAccessibilityPermissions() {
        Task { @MainActor in
            guard let accessibilityViewModel = accessibilityViewModel else { return }
            accessibilityViewModel.requestPermissions()
            
            if accessibilityViewModel.isPermissionGranted {
                registerCarbonHotkey()
            }
        }
    }
    
    /// Converts Cocoa modifier flags to Carbon flags for hotkey registration
    static func getCarbonFlagsFromCocoaFlags(cocoaFlags: NSEvent.ModifierFlags) -> UInt32 {
        let flags = cocoaFlags.rawValue
        var newFlags: Int = 0
        
        if ((flags & NSEvent.ModifierFlags.control.rawValue) > 0) {
            newFlags |= controlKey
        }
        if ((flags & NSEvent.ModifierFlags.command.rawValue) > 0) {
            newFlags |= cmdKey
        }
        if ((flags & NSEvent.ModifierFlags.shift.rawValue) > 0) {
            newFlags |= shiftKey
        }
        if ((flags & NSEvent.ModifierFlags.option.rawValue) > 0) {
            newFlags |= optionKey
        }
        if ((flags & NSEvent.ModifierFlags.capsLock.rawValue) > 0) {
            newFlags |= alphaLock
        }
        
        return UInt32(newFlags)
    }
    
    /// Registers the Carbon hotkey for Option+Tab
    private func registerCarbonHotkey() {
        let modifierFlags: UInt32 = AppDelegate.getCarbonFlagsFromCocoaFlags(cocoaFlags: .option)
        let keyCode = UInt32(kVK_Tab)
        
        var gMyHotKeyID = EventHotKeyID()
        gMyHotKeyID.id = keyCode
        gMyHotKeyID.signature = OSType("jswt".fourCharCodeValue)
        
        var eventTypePressed = EventTypeSpec()
        eventTypePressed.eventClass = OSType(kEventClassKeyboard)
        eventTypePressed.eventKind = OSType(kEventHotKeyPressed)
        
        _ = InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            Task { @MainActor in
                if let appDelegate = globalAppDelegate {
                    if let windowManager = appDelegate.windowManager {
                        if !windowManager.viewModel.isVisible {
                            windowManager.viewModel.handleOptionTab()
                            windowManager.show()
                        } else {
                            windowManager.viewModel.selectNext()
                        }
                    } else {
                        print("JustSwitch: Window manager is nil!")
                    }
                } else {
                    print("JustSwitch: Global app delegate is nil!")
                }
            }
            return noErr
        }, 1, &eventTypePressed, nil, nil)
        
        var eventTypeReleased = EventTypeSpec()
        eventTypeReleased.eventClass = OSType(kEventClassKeyboard)
        eventTypeReleased.eventKind = OSType(kEventHotKeyReleased)
        
        _ = InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            Task { @MainActor in
                globalAppDelegate?.windowManager?.viewModel.handleOptionTabRelease()
                
                if let windowManager = globalAppDelegate?.windowManager {
                    if windowManager.viewModel.isVisible {
                        let currentModifiers = NSEvent.modifierFlags
                        let optionHeld = currentModifiers.contains(.option)
                        if !optionHeld {
                            windowManager.viewModel.activateSelected()
                            windowManager.hide()
                        } else {
                            print("JustSwitch: Option still held, not hiding window")
                        }
                    } else {
                        print("JustSwitch: Window not visible, not hiding")
                    }
                } else {
                    print("JustSwitch: Window manager not found")
                }
                
                if let windowManager = globalAppDelegate?.windowManager {
                    if !windowManager.viewModel.isVisible {
                        windowManager.hide()
                    }
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    if let windowManager = globalAppDelegate?.windowManager {
                        if !windowManager.viewModel.isVisible {
                            windowManager.hide()
                        }
                    }
                }
            }
            
            return noErr
        }, 1, &eventTypeReleased, nil, nil)
        
        let registerStatus = RegisterEventHotKey(keyCode,
                                               modifierFlags,
                                               gMyHotKeyID,
                                               GetApplicationEventTarget(),
                                               0,
                                               &hotKeyRef)
        
        if registerStatus != noErr {
            print("JustSwitch: Failed to register Carbon hotkey: \(registerStatus)")
        }
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        menu.delegate = self
        
        let permissionUseCase = Container.shared.accessibilityPermissionUseCase
        let isPermissionGranted = permissionUseCase.checkPermissionStatus()
        
        if !isPermissionGranted {
            let accessibilityView = AccessibilityPermissionView()
            let accessibilityItem = NSMenuItem()
            accessibilityItem.view = accessibilityView
            menu.addItem(accessibilityItem)
            menu.addItem(NSMenuItem.separator())
        }
        
        menu.addItem(NSMenuItem(title: "About JustSwitch", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "JustSwitch"
        alert.informativeText = "A macOS window switcher\n\nPress Option+Tab to switch between applications"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc func checkAccessibility() {
        Task { @MainActor in
            accessibilityViewModel?.requestPermissions()
            
            if let isGranted = accessibilityViewModel?.isPermissionGranted {
                if isGranted {
                    registerCarbonHotkey()
                    setupMenu()
                }
            }
        }
    }
}

// MARK: NSMenuDelegate
extension AppDelegate: NSMenuDelegate {
    
    func menuWillOpen(_ menu: NSMenu) {
        setupMenu()
    }
    
    private func checkAndUpdatePermissionStatus() {
        let permissionUseCase = Container.shared.accessibilityPermissionUseCase
        let isPermissionGranted = permissionUseCase.checkPermissionStatus()
        
        if isPermissionGranted {
            if hotKeyRef == nil {
                registerCarbonHotkey()
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.setupMenu()
            }
        }
    }
}
