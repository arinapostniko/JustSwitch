//
//  WindowSwitcherView.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/3/25.
//

import SwiftUI

struct WindowSwitcherView: View {
    
    @ObservedObject var viewModel: WindowSwitcherViewModel
    
    private let maxHeight: CGFloat = {
        guard let screen = NSScreen.main else { return 600 }
        return screen.visibleFrame.height * 0.8
    }()
    
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
                let contentHeight = CGFloat(viewModel.applications.count) * 96 + 32
                let shouldScroll = contentHeight > maxHeight
                
                if shouldScroll {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(Array(viewModel.applications.enumerated()), id: \.element.id) { index, app in
                                    ApplicationRow(app: app,
                                                   isSelected: index == viewModel.selectedIndex)
                                    .padding(.horizontal, 16)
                                    .id("scroll-\(index)")
                                    .onTapGesture {
                                        viewModel.setSelectedIndex(index)
                                        viewModel.activateSelected()
                                    }
                                    .onHover { isHovered in
                                        if isHovered {
                                            viewModel.setSelectedIndexWithoutActivating(index)
                                        }
                                    }
                                    .onTapGesture(count: 2) {
                                        viewModel.setSelectedIndex(index)
                                        viewModel.activateSelected()
                                    }
                                }
                            }
                            .padding(.vertical, 16)
                        }
                        .frame(height: maxHeight)
                        .onChange(of: viewModel.selectedIndex) { newIndex in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo("scroll-\(newIndex)", anchor: .center)
                            }
                        }
                    }
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(Array(viewModel.applications.enumerated()), id: \.element.id) { index, app in
                            ApplicationRow(app: app,
                                           isSelected: index == viewModel.selectedIndex)
                            .padding(.horizontal, 16)
                            .onTapGesture {
                                viewModel.setSelectedIndex(index)
                                viewModel.activateSelected()
                            }
                            .onHover { isHovered in
                                if isHovered {
                                    viewModel.setSelectedIndexWithoutActivating(index)
                                }
                            }
                            .onTapGesture(count: 2) {
                                viewModel.setSelectedIndex(index)
                                viewModel.activateSelected()
                            }
                        }
                    }
                    .padding(.vertical, 16)
                }
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
        .frame(minWidth: 300)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 20)
    }
} 
