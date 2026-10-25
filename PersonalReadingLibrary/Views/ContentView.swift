
import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "books.vertical.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.blue)

                Text("Personal Reading Library")
                    .font(.title)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Organize your books and track your reading progress.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("My Library")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [Book.self, Category.self],
            inMemory: true
        )
}

