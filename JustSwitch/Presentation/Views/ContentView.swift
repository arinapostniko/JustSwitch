//
//  ContentView.swift
//  JustSwitch
//
//  Created by Arina Postnikova on 8/2/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "rectangle.stack")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("JustSwitch")
                .font(.title2)
            Text("A macOS window switcher")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(width: 200, height: 150)
    }
}

#Preview {
    ContentView()
}
