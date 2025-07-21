//
//  Facts.swift
//  OverUnder
//
//  Created by Andrew Pitblado on 2025-07-14.
//

import Foundation
import SwiftData

@Model
class Fact {
    var question: String
    var correctAnswer: Int
    var category: String?
    
    init(question: String, correctAnswer: Int, category: String? = nil) {
        self.question = question
        self.correctAnswer = correctAnswer
        self.category = category
    }
}
