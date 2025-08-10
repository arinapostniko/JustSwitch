//
//  ApplicationRow.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/3/25.
//

import SwiftUI

struct ApplicationRow: View {
    
    private enum Constants {
        static let iconSize: CGFloat = 48
    }
    
    let app: Application
    let isSelected: Bool
    
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 16) {
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .overlay(
                        Image(systemName: "app")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.system(size: 20))
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(app.name)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Text(app.windowTitle ?? "No window")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .contentShape(Rectangle())
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .onHover { isHovered = $0 }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            Color.white.opacity(0.15)
        } else if isHovered {
            Color.white.opacity(0.08)
        } else {
            Color.clear
        }
    }
}
