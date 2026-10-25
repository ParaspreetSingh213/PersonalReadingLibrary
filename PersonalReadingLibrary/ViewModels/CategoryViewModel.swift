
import Foundation
import Observation

@MainActor
@Observable
final class CategoryViewModel {
    var categories: [Category] = []
    var categoryName = ""
    var editingCategory: Category?
    var categoryToDelete: Category?

    var isShowingForm = false
    var isShowingDeleteConfirmation = false
    var isShowingError = false
    var errorMessage = ""

    private let persistenceService: PersistenceService

    init(persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
    }

    func loadCategories() {
        do {
            categories = try persistenceService.fetchCategories()
        } catch {
            showError("Unable to load categories: \(error.localizedDescription)")
        }
    }

    func startAdding() {
        categoryName = ""
        editingCategory = nil
        errorMessage = ""
        isShowingForm = true
    }

    func startEditing(category: Category) {
        categoryName = category.name
        editingCategory = category
        errorMessage = ""
        isShowingForm = true
    }

    func cancelForm() {
        isShowingForm = false
        categoryName = ""
        editingCategory = nil
        errorMessage = ""
    }

    func saveCategory() {
        let trimmedName = categoryName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty else {
            errorMessage = "Category name cannot be empty."
            return
        }

        let isDuplicate = categories.contains { category in
            let sameName = category.name.caseInsensitiveCompare(
                trimmedName
            ) == .orderedSame

            let isDifferentCategory =
                category.persistentModelID != editingCategory?.persistentModelID

            return sameName && isDifferentCategory
        }

        guard !isDuplicate else {
            errorMessage = "A category with this name already exists."
            return
        }

        do {
            if let editingCategory {
                try persistenceService.renameCategory(
                    category: editingCategory,
                    newName: trimmedName
                )
            } else {
                try persistenceService.addCategory(name: trimmedName)
            }

            categories = try persistenceService.fetchCategories()
            cancelForm()
        } catch {
            errorMessage = "Unable to save category: \(error.localizedDescription)"
        }
    }

    func requestDelete(category: Category) {
        do {
            let books = try persistenceService.fetchBooks()

            let containsBooks = books.contains { book in
                book.category.persistentModelID == category.persistentModelID
            }

            guard !containsBooks else {
                showError(
                    "This category contains books. Reassign its books before deleting it."
                )
                return
            }

            categoryToDelete = category
            isShowingDeleteConfirmation = true
        } catch {
            showError("Unable to check category: \(error.localizedDescription)")
        }
    }

    func deleteCategory() {
        guard let categoryToDelete else {
            return
        }

        do {
            try persistenceService.deleteCategory(
                category: categoryToDelete
            )

            categories = try persistenceService.fetchCategories()
            self.categoryToDelete = nil
        } catch {
            showError("Unable to delete category: \(error.localizedDescription)")
        }
    }

    private func showError(_ message: String) {
        errorMessage = message
        isShowingError = true
    }
}

