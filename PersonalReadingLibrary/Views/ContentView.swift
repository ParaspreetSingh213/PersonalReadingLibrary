
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        LibraryView(
            persistenceService: PersistenceService(
                modelContext: modelContext
            )
        )
    }
}

#Preview {
    ContentView()
        .modelContainer(
            for: [Book.self, Category.self],
            inMemory: true
        )
}

