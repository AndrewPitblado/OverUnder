//
//  Badge.swift
//  OverUnder
//
//  Created by Andrew Pitblado on 2025-07-14.
//

import Foundation
import SwiftData

@Model
class Badge {
    var name: String
    var desc: String
    var isUnlocked: Bool
    var unlockDate: Date?
    
    init(name: String, desc: String, isUnlocked: Bool = false, unlockDate: Date? = nil) {
        self.name = name
        self.desc = desc
        self.isUnlocked = isUnlocked
        self.unlockDate = unlockDate
    }
}
