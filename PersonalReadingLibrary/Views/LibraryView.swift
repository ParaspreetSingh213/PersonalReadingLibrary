
import SwiftUI

struct LibraryView: View {
    @State private var viewModel: LibraryViewModel

    init(persistenceService: PersistenceService) {
        _viewModel = State(
            initialValue: LibraryViewModel(
                persistenceService: persistenceService
            )
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if !viewModel.errorMessage.isEmpty {
                    ContentUnavailableView(
                        "Unable to Load Books",
                        systemImage: "exclamationmark.triangle",
                        description: Text(viewModel.errorMessage)
                    )
                } else if viewModel.books.isEmpty {
                    ContentUnavailableView(
                        "No Books Yet",
                        systemImage: "books.vertical",
                        description: Text("Your books will appear here.")
                    )
                } else {
                    List(viewModel.books) { book in
                        BookRowView(book: book)
                    }
                }
            }
            .navigationTitle("My Library")
            .task {
                viewModel.loadBooks()
            }
        }
    }
}

