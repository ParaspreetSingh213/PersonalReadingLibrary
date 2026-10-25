
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        TabView {
            LibraryView(
                persistenceService: PersistenceService(
                    modelContext: modelContext
                )
            )
            .tabItem {
                Label("Library", systemImage: "books.vertical")
            }

            CategoriesView(
                persistenceService: PersistenceService(
                    modelContext: modelContext
                )
            )
            .tabItem {
                Label("Categories", systemImage: "folder")
            }
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

