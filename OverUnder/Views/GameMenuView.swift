import SwiftUI

struct GameMenuView: View {
    var onStart: () -> Void = {}
    var onShowTutorial: () -> Void = {}
    var onShowSettings: () -> Void = {}
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 72))
                .foregroundStyle(.purple)
                .padding(.bottom, 8)
            
            Text("OverUnder")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 8)

            Text("Can you guess correctly? Beat your high score or master the streak!")
                .font(.title3)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            VStack(spacing: 18) {
                Button {
                    onStart()
                } label: {
                    Label("Start Game", systemImage: "play.circle.fill")
                        .font(.title2.weight(.bold))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    onShowTutorial()
                } label: {
                    Label("How to Play", systemImage: "questionmark.circle")
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    onShowSettings()
                } label: {
                    Label("Settings", systemImage: "gearshape")
                        .font(.title3)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    GameMenuView()
}
