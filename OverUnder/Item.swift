//
//  Item.swift
//  OverUnder
//
//  Created by Andrew Pitblado on 2025-07-14.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
