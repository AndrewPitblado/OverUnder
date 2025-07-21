import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 72))
                .foregroundStyle(.blue)
            Text("Profile")
                .font(.largeTitle)
                .padding(.top, 16)
            Text("Your stats, name, and settings will appear here.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
        .navigationTitle("Profile")
    }
}

#Preview {
    ProfileView()
}
