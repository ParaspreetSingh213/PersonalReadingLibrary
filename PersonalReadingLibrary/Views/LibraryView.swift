import SwiftUI
import SwiftData

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
        @Bindable var model = viewModel

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
                    List {
                        Section("Filter and Sort") {
                            Picker(
                                "Category",
                                selection: $model.selectedCategoryID
                            ) {
                                Text("All Categories")
                                    .tag(nil as PersistentIdentifier?)

                                ForEach(viewModel.categories) { category in
                                    Text(category.name)
                                        .tag(Optional(category.persistentModelID))
                                }
                            }

                            Picker(
                                "Reading Status",
                                selection: $model.selectedStatus
                            ) {
                                Text("All Statuses")
                                    .tag("All Statuses")

                                Text("Not Started")
                                    .tag("Not Started")

                                Text("Reading")
                                    .tag("Reading")

                                Text("Completed")
                                    .tag("Completed")
                            }

                            Picker(
                                "Sort By",
                                selection: $model.sortOption
                            ) {
                                ForEach(LibrarySortOption.allCases) { option in
                                    Text(option.rawValue)
                                        .tag(option)
                                }
                            }
                        }

                        Section("Books") {
                            if viewModel.filteredBooks.isEmpty {
                                Text("No books match your search and filters.")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(viewModel.filteredBooks) { book in
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
                    }
                }
            }
            .navigationTitle("My Library")
            .searchable(
                text: $model.searchText,
                prompt: "Search by title or author"
            )
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

