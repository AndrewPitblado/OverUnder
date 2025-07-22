//
//  GameView.swift
//  OverUnder
//
//  Created by Andrew Pitblado on 2025-07-14.
//
//  Added animations to question text on correct answer, including scale and color.
//  Background color changes based on score threshold, with smooth animations for feedback.

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

    @State private var showCorrectAnimation = false
    @State private var bgColor: Color = .clear
    
    @State private var userGuess: String = ""
    @State private var isGuessingExact: Bool = false
    
    @State private var showingMenu: Bool = true
    @State private var showTutorial: Bool = false // For future use
    @State private var showSettings: Bool = false // For future use
    
    let levelColors: [Color] = [
        .white.opacity(0.7),
        .green,
        .yellow,
        .orange,
        .red
    ]
    var body: some View {
        if showingMenu {
            GameMenuView(
                onStart: { showingMenu = false },
                onShowTutorial: { showTutorial = true },
                onShowSettings: { showSettings = true }
            )
            .sheet(isPresented: $showTutorial, content: {
                TutorialView(showTutorial: $showTutorial)
            })
            .sheet(isPresented: $showSettings) {
                SettingsView(showSettings: $showSettings)
            }
        } else {
            ZStack {
                bgColor
                    .ignoresSafeArea()
                    .animation(.easeInOut, value: bgColor)
                
                VStack(spacing: 20) {
                    if let fact = currentFact ?? previewFact {
                        Text(fact.question)
                            .font(.largeTitle)
                            .multilineTextAlignment(.center)
                            .padding()
                            .scaleEffect(showCorrectAnimation ? 1.1 : 1.0)
                            .foregroundColor(showCorrectAnimation ? .green : .primary)
                            .animation(.spring(), value: showCorrectAnimation)

                        if isGuessingExact {
                            TextField("Enter your guess", text: $userGuess)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .font(.largeTitle)
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Button("Submit") {
                                submitExactGuess()
                            }
                            .font(.title2.weight(.bold))
                            .padding()
                            .buttonStyle(.borderedProminent)
                            .disabled(userGuess.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        } else {
                            Text("🧠 \(displayedValue)")
                                .font(.largeTitle)
                                .bold()
                            Spacer()
                            
                            HStack(spacing: 40) {
                                VStack{
                                    Text("Over")
                                        .font(.title2)
                                        .padding()
                                        .bold()
                                    
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
                                        .bold()
                                    
                                    ArrowButton(direction: .down, animate: $animateDown) {
                                        animateDown = true
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { animateDown = false }
                                        checkAnswer(over: false)
                                    }
                                }
                            }
                        }
                        
                    } else {
                        Text("Loading...")
                    }
                    
                    Text("Score: \(score) • Streak: \(streak)")
                        .font(.title3)
                        .padding()
                        .fontWeight(.semibold)

                    Text("🏆 High Score: \(highScore)")
                        .font(.title3)
                        .foregroundStyle(.gray)
                        .padding()
                    Spacer()
                    
                    Button("Return to Menu") {
                        showingMenu = true
                        // Reset game state if desired
                        score = 0
                        streak = 0
                        level = 1
                        bgColor = .clear
                    }
                    .font(.footnote)
                    .padding(.top)
                    .opacity(showingMenu ? 0 : 1)
                }
            }
            .onAppear {
                if previewFact == nil {
                    loadNextFact()
                }
                prepareHaptics()
            }
        }
        
    }
        

    func backgroundColor(for level: Int) -> Color{
        let index = min(level / 10, levelColors.count - 1)
        return levelColors[index]
    }

    func loadNextFact() {
        if let fact = facts.randomElement() {
            currentFact = fact
            isGuessingExact = (level > 1 && level % 10 == 0)
            userGuess = ""
            if isGuessingExact {
                // In guess-exact mode, no offset; user must guess exact correctAnswer
                displayedValue = 0
            } else {
                let baseMargin = 40 // Start margin
                let margin = max(1, Int(Double(baseMargin) * pow(0.9, Double(level))))
                let offset = Int.random(in: -margin...margin)
                displayedValue = fact.correctAnswer + offset
            }
        }
    }

    func checkAnswer(over: Bool) {
        guard let fact = currentFact else { return }
        let isActuallyOver = displayedValue < fact.correctAnswer
        
        if isActuallyOver == over {
            showCorrectAnimation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { showCorrectAnimation = false }
            
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
            
            bgColor = backgroundColor(for: level)
            
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
            
            loadNextFact()
        } else {
            playErrorHaptic()
            score = 0
            streak = 0
            level = 1
            bgColor = .blue
            showCorrectAnimation = false
            isGuessingExact = false
            loadNextFact()
        }
    }
    
    func submitExactGuess() {
        guard let fact = currentFact else { return }
        guard let guessInt = Int(userGuess.trimmingCharacters(in: .whitespacesAndNewlines)) else { return }
        
        if guessInt == fact.correctAnswer {
            showCorrectAnimation = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { showCorrectAnimation = false }
            
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
            
            bgColor = backgroundColor(for: level)
            
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
            
            isGuessingExact = false
            loadNextFact()
        } else {
            playErrorHaptic()
            score = 0
            streak = 0
            level = 1
            bgColor = .blue
            showCorrectAnimation = false
            isGuessingExact = false
            loadNextFact()
        }
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
            .foregroundStyle(.primary)
            .font(.system(size: 150))
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
