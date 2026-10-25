
import SwiftUI
import SwiftData

@main
struct PersonalReadingLibraryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            Book.self,
            Category.self
        ])
    }
}

