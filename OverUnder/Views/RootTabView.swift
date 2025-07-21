import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            GameView()
                .tabItem {
                    Label("Game", systemImage: "gamecontroller.fill")
                }
            AwardsView()
                .tabItem {
                    Label("Awards", systemImage: "medal.fill")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
    }
}

#Preview {
    RootTabView()
}
