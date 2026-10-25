
import SwiftUI
import SwiftData

struct BookFormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: BookFormViewModel

    let onSaved: () -> Void

    init(
        persistenceService: PersistenceService,
        book: Book? = nil,
        onSaved: @escaping () -> Void
    ) {
        _viewModel = State(
            initialValue: BookFormViewModel(
                persistenceService: persistenceService,
                book: book
            )
        )

        self.onSaved = onSaved
    }

    var body: some View {
        @Bindable var model = viewModel

        NavigationStack {
            Form {
                Section("Book Information") {
                    TextField("Book Title", text: $model.title)

                    TextField("Author", text: $model.author)
                }

                Section("Reading Progress") {
                    TextField("Total Pages", text: $model.totalPages)
                        .keyboardType(.numberPad)

                    TextField("Pages Read", text: $model.pagesRead)
                        .keyboardType(.numberPad)
                }

                Section("Category") {
                    if viewModel.categories.isEmpty {
                        Text("Create a category in the Categories tab before adding a book.")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Category", selection: $model.selectedCategoryID) {
                            ForEach(viewModel.categories) { category in
                                Text(category.name)
                                    .tag(Optional(category.persistentModelID))
                            }
                        }
                    }
                }

                if !viewModel.errorMessage.isEmpty {
                    Section {
                        Text(viewModel.errorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Book" : "Add Book")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.saveBook() {
                            onSaved()
                            dismiss()
                        }
                    }
                    .disabled(viewModel.categories.isEmpty)
                }
            }
            .onAppear {
                viewModel.loadCategories()
            }
        }
    }
}

