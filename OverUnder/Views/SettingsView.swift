//
//  SettingsView.swift
//  OverUnder
//
//  Created by Andrew Pitblado on 2025-07-22.
//

import SwiftUI

struct SettingsView: View {
    @Binding var showSettings: Bool
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
            Text("(Settings options coming soon!)")
                .padding()
            Button("Close") { showSettings = false }
                .padding()
        }    }
}
