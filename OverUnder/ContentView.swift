//
//  ContentView.swift
//  OverUnder
//
//  Created by Andrew Pitblado on 2025-07-14.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        GameView()
    }
}

#Preview {
    let mockFact = Fact(
        question: "How many moons does Jupiter have?",
        correctAnswer: 95,
        category: "Science"
    )

    return GameView(previewFact: mockFact)
}
