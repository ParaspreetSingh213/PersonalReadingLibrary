import SwiftUI

struct LibraryView: View {
    @State private var viewModel: LibraryViewModel
    @State private var isShowingAddBook = false

    private let persistenceService: PersistenceService

    init(persistenceService: PersistenceService) {
        self.persistenceService = persistenceService

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
                        description: Text("Tap + to add your first book.")
                    )
                } else {
                    List(viewModel.books) { book in
                        NavigationLink {
                            BookDetailView(
                                book: book,
                                persistenceService: persistenceService,
                                onChanged: {
                                    viewModel.loadBooks()
                                }
                            )
                        } label: {
                            BookRowView(book: book)
                        }
                    }
                }
            }
            .navigationTitle("My Library")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingAddBook = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Book")
                }
            }
            .sheet(isPresented: $isShowingAddBook) {
                BookFormView(
                    persistenceService: persistenceService,
                    onSaved: {
                        viewModel.loadBooks()
                    }
                )
            }
            .onAppear {
                viewModel.loadBooks()
            }
        }
    }
}

