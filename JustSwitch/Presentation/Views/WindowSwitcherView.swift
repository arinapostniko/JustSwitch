//
//  WindowSwitcherView.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/3/25.
//

import SwiftUI

struct WindowSwitcherView: View {
    
    @ObservedObject var viewModel: WindowSwitcherViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.applications.isEmpty {
                VStack {
                    Spacer()
                    
                    Image(systemName: "rectangle.stack")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No applications found")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .frame(height: 200)
            } else {
                let maxHeight: CGFloat = 400
                let rowHeight: CGFloat = 40
                let calculatedHeight = min(CGFloat(viewModel.applications.count) * rowHeight, maxHeight)
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(viewModel.applications.enumerated()), id: \.element.id) { index, app in
                            ApplicationRow(
                                app: app,
                                isSelected: index == viewModel.selectedIndex
                            )
                            .onTapGesture {
                                print("ApplicationRow tapped: \(app.name)")
                                viewModel.setSelectedIndex(index)
                                viewModel.activateSelected()
                            }
                            .onHover { isHovered in
                                if isHovered {
                                    viewModel.setSelectedIndexWithoutActivating(index)
                                }
                            }
                            .onTapGesture(count: 2) {
                                print("ApplicationRow double-tapped: \(app.name)")
                                viewModel.setSelectedIndex(index)
                                viewModel.activateSelected()
                            }
                        }
                    }
                }
                .frame(height: calculatedHeight)
            }
            
            Divider()
            
            HStack {
                Text("Hold ⌥ and use ⇥ or ↑↓ to navigate, release ⌥ to select")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
        }
        .frame(width: 320)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 20)
        .onAppear {
            setupKeyboardHandling()
        }
    }
    
    private func setupKeyboardHandling() {
        NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { event in
            switch event.keyCode {
            case 48: /// Tab key
                if event.modifierFlags.contains(.option) {
                    viewModel.selectNext()
                    return nil
                }
                return event
            case 125: /// Down arrow
                viewModel.selectNext()
                return nil
            case 126: /// Up arrow
                viewModel.selectPrevious()
                return nil
            case 53: /// Escape
                viewModel.hide()
                return nil
            case 49: /// Space bar - for testing
                viewModel.activateSelected()
                return nil
            case 36: /// Return/Enter key - for testing hide
                viewModel.hide()
                return nil
            case 1: /// 'a' key - for testing WindowManager hide
                if let appDelegate = globalAppDelegate {
                    appDelegate.windowManager?.hide()
                }
                return nil
            default:
                return event
            }
        }
    }
} 
