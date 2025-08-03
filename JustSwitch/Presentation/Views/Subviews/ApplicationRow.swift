//
//  ApplicationRow.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/3/25.
//

import SwiftUI

struct ApplicationRow: View {
    
    private enum Constants {
        static let iconSize: CGFloat = 36
    }
    
    let app: Application
    let isSelected: Bool
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
            } else {
                Image(systemName: "app")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Constants.iconSize, height: Constants.iconSize)
                    .foregroundColor(.gray)
            }
            
            Text(app.name)
                .font(.system(size: 16, weight: .bold))
                .lineLimit(1)
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(backgroundColor)
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color.accentColor.opacity(0.15)
        } else if isHovered {
            return Color.primary.opacity(0.05)
        } else {
            return Color.clear
        }
    }
}
