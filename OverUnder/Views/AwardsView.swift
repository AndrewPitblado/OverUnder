import SwiftUI

struct AwardsView: View {
    var body: some View {
        VStack {
            Image(systemName: "medal.fill")
                .font(.system(size: 72))
                .foregroundStyle(.yellow)
            Text("Your Awards")
                .font(.largeTitle)
                .padding(.top, 16)
            Text("All your medals, badges, and achievements will be shown here.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
        .navigationTitle("Awards")
    }
}

#Preview {
    AwardsView()
}
