import Foundation
import SwiftData

enum PersistenceError: LocalizedError {
    case categoryContainsBooks

    var errorDescription: String? {
        switch self {
        case .categoryContainsBooks:
            return "This category contains books. Reassign its books before deleting it."
        }
    }
}

@MainActor
final class PersistenceService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    private func saveChanges() throws {
        do {
            try modelContext.save()
        } catch {
            modelContext.rollback()
            throw error
        }
    }

    func fetchBooks() throws -> [Book] {
        let descriptor = FetchDescriptor<Book>(
            sortBy: [SortDescriptor(\Book.dateAdded, order: .reverse)]
        )

        return try modelContext.fetch(descriptor)
    }

    func fetchCategories() throws -> [Category] {
        let descriptor = FetchDescriptor<Category>(
            sortBy: [SortDescriptor(\Category.name)]
        )

        return try modelContext.fetch(descriptor)
    }

    func addBook(
        title: String,
        author: String,
        totalPages: Int,
        pagesRead: Int,
        category: Category
    ) throws {
        let book = Book(
            title: title,
            author: author,
            totalPages: totalPages,
            pagesRead: pagesRead,
            category: category
        )

        modelContext.insert(book)
        try saveChanges()
    }

    func updateBook(
        book: Book,
        title: String,
        author: String,
        totalPages: Int,
        pagesRead: Int,
        category: Category
    ) throws {
        book.title = title
        book.author = author
        book.totalPages = totalPages
        book.pagesRead = pagesRead
        book.category = category

        try saveChanges()
    }

    func deleteBook(book: Book) throws {
        modelContext.delete(book)
        try saveChanges()
    }

    func addCategory(name: String) throws {
        let category = Category(name: name)

        modelContext.insert(category)
        try saveChanges()
    }

    func renameCategory(category: Category, newName: String) throws {
        category.name = newName
        try saveChanges()
    }

    func deleteCategory(category: Category) throws {
        let books = try fetchBooks()

        let hasBooks = books.contains { book in
            book.category.persistentModelID == category.persistentModelID
        }

        guard !hasBooks else {
            throw PersistenceError.categoryContainsBooks
        }

        modelContext.delete(category)
        try saveChanges()
    }
}

