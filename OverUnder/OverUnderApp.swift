//
//  OverUnderApp.swift
//  OverUnder
//
//  Created by Andrew Pitblado on 2025-07-14.
//

import SwiftUI
import SwiftData
@main
struct OverUnderApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Fact.self, Badge.self])
        let container = try! ModelContainer(for: schema)
        
        let context = container.mainContext
        let badgeCount = try? context.fetchCount(FetchDescriptor<Badge>())
        if badgeCount == 0 {
            let badges = [
                Badge(name: "Hot Streak", desc: "Get 5 in a row"),
                Badge(name: "Brainiac", desc: "Reach Level 10"),
                Badge(name: "Bullseye", desc: "Guess the exact value")
            ]
            for badge in badges {
                context.insert(badge)
            }
        }
        
        let factCount = try? context.fetchCount(FetchDescriptor<Fact>())
        if factCount == 0 {
            let facts = DataManager.loadInitialFacts()
            for fact in facts {
                context.insert(fact)
            }
        }
        
        return container
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
