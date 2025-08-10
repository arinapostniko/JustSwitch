//
//  KeyableWindow.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/9/25.
//

import AppKit

class KeyableWindow: NSWindow {
    
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}
