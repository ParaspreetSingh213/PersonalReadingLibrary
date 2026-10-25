import SwiftUI

struct BookDetailView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: BookFormViewModel
    @State private var isShowingEdit = false
    @State private var isShowingDeleteConfirmation = false
    @State private var isShowingDeleteError = false

    let book: Book
    let persistenceService: PersistenceService
    let onChanged: () -> Void

    init(
        book: Book,
        persistenceService: PersistenceService,
        onChanged: @escaping () -> Void
    ) {
        self.book = book
        self.persistenceService = persistenceService
        self.onChanged = onChanged

        _viewModel = State(
            initialValue: BookFormViewModel(
                persistenceService: persistenceService,
                book: book
            )
        )
    }

    var body: some View {
        Form {
            Section("Book Information") {
                LabeledContent("Title", value: book.title)
                LabeledContent("Author", value: book.author)
                LabeledContent("Category", value: book.category.name)

                LabeledContent(
                    "Date Added",
                    value: book.dateAdded.formatted(
                        date: .abbreviated,
                        time: .omitted
                    )
                )
            }

            Section("Reading Progress") {
                LabeledContent(
                    "Total Pages",
                    value: "\(book.totalPages)"
                )

                LabeledContent(
                    "Pages Read",
                    value: "\(book.pagesRead)"
                )

                LabeledContent(
                    "Status",
                    value: viewModel.readingStatus
                )

                ProgressView(value: viewModel.progress)

                Text("\(viewModel.progressPercentage)% Complete")
                    .font(.headline)
                    .foregroundStyle(.blue)
            }

            Section {
                Button("Edit Book") {
                    isShowingEdit = true
                }

                Button("Delete Book", role: .destructive) {
                    isShowingDeleteConfirmation = true
                }
            }
        }
        .navigationTitle("Book Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingEdit) {
            BookFormView(
                persistenceService: persistenceService,
                book: book,
                onSaved: {
                    onChanged()
                }
            )
        }
        .confirmationDialog(
            "Delete Book?",
            isPresented: $isShowingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if viewModel.deleteBook() {
                    onChanged()
                    dismiss()
                } else {
                    isShowingDeleteError = true
                }
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This book will be permanently deleted.")
        }
        .alert(
            "Unable to Delete Book",
            isPresented: $isShowingDeleteError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

