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
                        .foregroundColor(.white.opacity(0.4))
                    
                    Text("No applications found")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                }
                .frame(height: 200)
            } else {
                let rowHeight: CGFloat = 72
                let spacing: CGFloat = 4
                let verticalPadding: CGFloat = 16
                let contentHeight = CGFloat(viewModel.applications.count) * rowHeight + 
                                  CGFloat(max(0, viewModel.applications.count - 1)) * spacing + 
                                  verticalPadding
                let shouldScroll = contentHeight > maxHeight
                
                if shouldScroll {
                    ScrollViewReader { proxy in
                        ScrollView {
                            LazyVStack(spacing: 4) {
                                ForEach(Array(viewModel.applications.enumerated()), id: \.element.id) { index, app in
                                    ApplicationRow(app: app,
                                                   isSelected: index == viewModel.selectedIndex)
                                    .padding(.horizontal, 8)
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
                            .padding(.vertical, 8)
                        }
                        .frame(height: maxHeight)
                        .onChange(of: viewModel.selectedIndex) { newIndex in
                            withAnimation(.easeInOut(duration: 0.3)) {
                                proxy.scrollTo("scroll-\(newIndex)", anchor: .center)
                            }
                        }
                    }
                } else {
                    LazyVStack(spacing: 4) {
                        ForEach(Array(viewModel.applications.enumerated()), id: \.element.id) { index, app in
                            ApplicationRow(app: app,
                                           isSelected: index == viewModel.selectedIndex)
                            .padding(.horizontal, 8)
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
                    .padding(.vertical, 8)
                }
            }
            

        }
        .frame(minWidth: 400)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.black.opacity(0.3))
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.5), radius: 30, x: 0, y: 10)
    }
} 
