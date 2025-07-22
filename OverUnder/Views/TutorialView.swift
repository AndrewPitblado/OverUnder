//
//  TutorialView.swift
//  OverUnder
//
//  Created by Andrew Pitblado on 2025-07-22.
//

import SwiftUI

struct TutorialView: View {
    @Binding var showTutorial: Bool
    var body: some View {
        VStack {
            Text("How to Play")
                .font(.largeTitle)
                .padding()
            Text("Guess whether the real answer is over or under the shown value. Every 10th level, guess the exact number!")
                .padding()
            Button("Close") { showTutorial = false }
                .padding()
        }
    }
}
    

