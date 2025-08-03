//
//  AccessibilityAlertView.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/2/25.
//

import SwiftUI

struct AccessibilityAlertView: View {
    
    @ObservedObject var viewModel: AccessibilityViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text("Accessibility Permissions Required")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(viewModel.permissionAlertMessage)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Button("Open Settings") {
                    viewModel.openSystemPreferences()
                }
//                .buttonStyle(.borderedProminent)
                
                Button("Retry") {
                    viewModel.retryPermissionRequest()
                }
                .buttonStyle(.bordered)
                
                Button("Cancel") {
                    viewModel.showPermissionAlert = false
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(24)
        .frame(width: 400)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 20)
    }
} 
