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
    
    /// Accessibility alert window
    var accessibilityAlertWindow: AccessibilityAlertWindow?
    
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
        accessibilityAlertWindow = Container.shared.makeAccessibilityAlertWindow(viewModel: accessibilityViewModel!)
    }
    
    private func requestAccessibilityPermissions() {
        Task { @MainActor in
            guard let accessibilityViewModel = accessibilityViewModel else { return }
            accessibilityViewModel.checkPermissionStatus()
            
            if accessibilityViewModel.isPermissionGranted {
                registerCarbonHotkey()
            } else {
                accessibilityViewModel.requestPermissions()
                
                if !accessibilityViewModel.isPermissionGranted {
                    showAccessibilityAlert()
                }
            }
        }
    }
    
    private func showAccessibilityAlert() {
        Task { @MainActor in
            guard let accessibilityAlertWindow = accessibilityAlertWindow else { return }
            accessibilityAlertWindow.show()
        }
    }
    
    private func openAccessibilitySettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
            NSWorkspace.shared.open(url)
        } else {
            NSWorkspace.shared.open(URL(fileURLWithPath: "/System/Library/PreferencePanes/Security.prefPane"))
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
        
        if registerStatus == noErr {
            print("JustSwitch: Carbon hotkey registered successfully!")
        } else {
            print("JustSwitch: Failed to register Carbon hotkey: \(registerStatus)")
        }
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Test Window Switcher", action: #selector(testWindowSwitcher), keyEquivalent: "t"))
        menu.addItem(NSMenuItem(title: "Hide Window Switcher", action: #selector(hideWindowSwitcher), keyEquivalent: "h"))
        menu.addItem(NSMenuItem(title: "Check Accessibility", action: #selector(checkAccessibility), keyEquivalent: "a"))
        menu.addItem(NSMenuItem(title: "About JustSwitch", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem?.menu = menu
    }
    
    @objc func testWindowSwitcher() {
        Task { @MainActor in
            windowManager?.viewModel.handleOptionTab()
            windowManager?.show()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            Task { @MainActor in
                print("JustSwitch: Window visible: \(self.windowManager?.viewModel.isVisible ?? false)")
                if let window = self.windowManager?.window {
                    print("JustSwitch: Window is key: \(window.isKeyWindow)")
                    print("JustSwitch: Window is visible: \(window.isVisible)")
                }
            }
        }
    }
    
    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = "JustSwitch"
        alert.informativeText = "A macOS window switcher\n\nPress Option+Tab to switch between applications"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    @objc func showWindowSwitcher() {
        Task { @MainActor in
            windowManager?.show()
        }
    }
    
    @objc func hideWindowSwitcher() {
        Task { @MainActor in
            windowManager?.hide()
        }
    }
    
    @objc func checkAccessibility() {
        Task { @MainActor in
            accessibilityViewModel?.checkPermissionStatus()
            
            if let isGranted = accessibilityViewModel?.isPermissionGranted {
                if isGranted {
                    registerCarbonHotkey()
                } else {
                    showAccessibilityAlert()
                }
            }
        }
    }
}
