//
//  DataManager.swift
//  OverUnder
//
//  Created by Andrew Pitblado on 2025-07-14.
//

import Foundation

class DataManager {
    static func loadInitialFacts() -> [Fact] {
        guard let url = Bundle.main.url(forResource: "facts", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let rawFacts = try? JSONDecoder().decode([RawFact].self, from: data) else {
            return []
        }
        return rawFacts.map { Fact(question: $0.question, correctAnswer: $0.correctAnswer, category: $0.category) }
    }
}

// Helper struct for decoding JSON
private struct RawFact: Codable {
    let question: String
    let correctAnswer: Int
    let category: String?
}
