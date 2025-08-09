//
//  ApplicationRow.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/3/25.
//

import SwiftUI

struct ApplicationRow: View {
    
    private enum Constants {
        static let iconSize: CGFloat = 64
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
        .cornerRadius(12)
        .contentShape(Rectangle())
        .onHover { isHovered = $0 }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            Color.accentColor.opacity(0.6)
        } else if isHovered {
            Color.primary.opacity(0.1)
        } else {
            Color.primary.opacity(0.05)
        }
    }
}
