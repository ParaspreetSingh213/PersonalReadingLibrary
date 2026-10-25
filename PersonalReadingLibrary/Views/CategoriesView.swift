
import SwiftUI

struct CategoriesView: View {
    @State private var viewModel: CategoryViewModel

    init(persistenceService: PersistenceService) {
        _viewModel = State(
            initialValue: CategoryViewModel(
                persistenceService: persistenceService
            )
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.categories.isEmpty {
                    ContentUnavailableView(
                        "No Categories Yet",
                        systemImage: "folder",
                        description: Text("Add a category to organize your books.")
                    )
                } else {
                    List {
                        ForEach(viewModel.categories) { category in
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(category.name)
                                        .font(.headline)

                                    Text("\(category.books.count) books")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                Button {
                                    viewModel.startEditing(category: category)
                                } label: {
                                    Image(systemName: "pencil")
                                }
                                .buttonStyle(.borderless)

                                Button {
                                    viewModel.requestDelete(category: category)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(.red)
                                }
                                .buttonStyle(.borderless)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.startAdding()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add Category")
                }
            }
            .sheet(isPresented: $viewModel.isShowingForm) {
                CategoryFormView(viewModel: viewModel)
            }
            .confirmationDialog(
                "Delete Category?",
                isPresented: $viewModel.isShowingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    viewModel.deleteCategory()
                }

                Button("Cancel", role: .cancel) {
                    viewModel.categoryToDelete = nil
                }
            } message: {
                Text("Are you sure you want to delete this category?")
            }
            .alert("Category Error", isPresented: $viewModel.isShowingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
            .onAppear {
                viewModel.loadCategories()
            }
        }
    }
}

private struct CategoryFormView: View {
    @Bindable var viewModel: CategoryViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section("Category Name") {
                    TextField(
                        "Enter category name",
                        text: $viewModel.categoryName
                    )
                }

                if !viewModel.errorMessage.isEmpty {
                    Text(viewModel.errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
            }
            .navigationTitle(
                viewModel.editingCategory == nil
                    ? "Add Category"
                    : "Rename Category"
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.cancelForm()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.saveCategory()
                    }
                }
            }
        }
    }
}

