//
//  GameView.swift
//  OverUnder
//
//  Created by Andrew Pitblado on 2025-07-14.
//

import SwiftUI
import SwiftData
import CoreHaptics

struct GameView: View {
    @AppStorage("highScore") private var highScore: Int = 0
    @AppStorage("bestStreak") private var bestStreak: Int = 0
    @Environment(\.modelContext) private var context
    @Query private var facts: [Fact]
    @Query private var badges: [Badge]
    
    @State private var currentFact: Fact?
    @State private var displayedValue: Int = 0
    @State private var level: Int = 1
    @State private var score: Int = 0
    @State private var streak: Int = 0
    var previewFact: Fact?
    
    @State private var engine: CHHapticEngine?
    @State private var animateUp = false
    @State private var animateDown = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let fact = currentFact ?? previewFact {
                Text(fact.question)
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text("🧠 \(displayedValue)")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                
                HStack(spacing: 40) {
                    VStack{
                        Text("Over")
                            .font(.title2)
                            .padding()
                        ArrowButton(direction: .up, animate: $animateUp) {
                            animateUp = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { animateUp = false }
                            checkAnswer(over: true)
                        }
                    }
                    VStack{
                        Text("Under")
                            .font(.title2)
                            .padding()
                        ArrowButton(direction: .down, animate: $animateDown) {
                            animateDown = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { animateDown = false }
                            checkAnswer(over: false)
                        }
                    }
                }
                
            } else {
                Text("Loading...")
            }
            
            Text("Score: \(score) • Streak: \(streak)")
                .font(.title3)
                .padding()

            Text("🏆 High Score: \(highScore)")
                .font(.title3)
                .foregroundStyle(.gray)
                .padding()
            Spacer()
        }
        .onAppear {
            if previewFact == nil {
                loadNextFact()
            }
            prepareHaptics()
        }
    }

    func loadNextFact() {
        if let fact = facts.randomElement() {
            currentFact = fact
            let baseMargin = 40 // Start margin
            let margin = max(1, Int(Double(baseMargin) * pow(0.9, Double(level))))
            let offset = Int.random(in: -margin...margin)
            displayedValue = fact.correctAnswer + offset
        }
    }

    func checkAnswer(over: Bool) {
        guard let fact = currentFact else { return }
        let isActuallyOver = displayedValue < fact.correctAnswer
        
        if isActuallyOver == over {
            score += 1
            streak += 1
            level += 1

            if score > highScore {
                highScore = score
            }
            if streak > bestStreak {
                bestStreak = streak
            }
            
            playSuccessHaptic()

            // Badge unlock logic will go here 👇
            if streak == 5 {
                unlockBadge(name: "Hot Streak")
            }

            func unlockBadge(name: String) {
                guard let badge = badges.first(where: { $0.name == name && !$0.isUnlocked }) else { return }
                badge.isUnlocked = true
                badge.unlockDate = Date()
                try? context.save() // Optional in SwiftData but safe here
            }
        } else {
            playErrorHaptic()
            score = 0
            streak = 0
            level = 1
        }
        
        loadNextFact()
    }
    
    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch { }
    }
    func playSuccessHaptic() {
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: 0)
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch { }
    }
    func playErrorHaptic() {
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.3)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.3)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch { }
    }
}

enum ArrowDirection { case up, down }
struct ArrowButton: View {
    let direction: ArrowDirection
    @Binding var animate: Bool
    @State private var offsetY: CGFloat = 0
    let action: () -> Void

    var body: some View {
        let arrow = direction == .up ? "⬆️" : "⬇️"
        Text(arrow)
            .font(.system(size: 110))
            .offset(y: offsetY)
            .animation(.spring(), value: offsetY)
            .gesture(
                DragGesture(minimumDistance: 30, coordinateSpace: .local)
                    .onEnded { value in
                        if direction == .up && value.translation.height < -30 {
                            offsetY = -40
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                offsetY = 0
                            }
                            action()
                        } else if direction == .down && value.translation.height > 30 {
                            offsetY = 40
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                offsetY = 0
                            }
                            action()
                        }
                    }
            )
            .onTapGesture {
                action()
            }
    }
}
