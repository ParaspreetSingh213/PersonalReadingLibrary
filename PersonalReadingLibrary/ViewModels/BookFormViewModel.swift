import Foundation
import Observation
import SwiftData

@MainActor
@Observable
final class BookFormViewModel {
    var title = ""
    var author = ""
    var totalPages = ""
    var pagesRead = "0"

    var categories: [Category] = []
    var selectedCategoryID: PersistentIdentifier?
    var errorMessage = ""

    private let persistenceService: PersistenceService
    private let book: Book?

    var isEditing: Bool {
        book != nil
    }

    var readingStatus: String {
        guard let book else {
            return ReadingStatus.notStarted.rawValue
        }

        return ReadingService.getStatus(
            pagesRead: book.pagesRead,
            totalPages: book.totalPages
        ).rawValue
    }

    var progressPercentage: Int {
        guard let book else {
            return 0
        }

        return ReadingService.getProgressPercentage(
            pagesRead: book.pagesRead,
            totalPages: book.totalPages
        )
    }

    var progress: Double {
        guard let book else {
            return 0
        }

        return ReadingService.getProgress(
            pagesRead: book.pagesRead,
            totalPages: book.totalPages
        )
    }

    init(persistenceService: PersistenceService, book: Book? = nil) {
        self.persistenceService = persistenceService
        self.book = book

        if let book {
            title = book.title
            author = book.author
            totalPages = String(book.totalPages)
            pagesRead = String(book.pagesRead)
            selectedCategoryID = book.category.persistentModelID
        }
    }

    func loadCategories() {
        do {
            categories = try persistenceService.fetchCategories()

            if selectedCategoryID == nil {
                selectedCategoryID = categories.first?.persistentModelID
            }

            errorMessage = ""
        } catch {
            errorMessage = "Unable to load categories: \(error.localizedDescription)"
        }
    }

    func saveBook() -> Bool {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAuthor = author.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedTitle.isEmpty else {
            errorMessage = "Please enter a book title."
            return false
        }

        guard !trimmedAuthor.isEmpty else {
            errorMessage = "Please enter an author name."
            return false
        }

        guard let total = Int(totalPages), total > 0 else {
            errorMessage = "Total pages must be a whole number greater than zero."
            return false
        }

        guard let read = Int(pagesRead), read >= 0 else {
            errorMessage = "Pages read must be a whole number of zero or greater."
            return false
        }

        guard read <= total else {
            errorMessage = "Pages read cannot exceed total pages."
            return false
        }

        guard let category = categories.first(where: {
            $0.persistentModelID == selectedCategoryID
        }) else {
            errorMessage = "Please create and select a category first."
            return false
        }

        do {
            if let book {
                try persistenceService.updateBook(
                    book: book,
                    title: trimmedTitle,
                    author: trimmedAuthor,
                    totalPages: total,
                    pagesRead: read,
                    category: category
                )
            } else {
                try persistenceService.addBook(
                    title: trimmedTitle,
                    author: trimmedAuthor,
                    totalPages: total,
                    pagesRead: read,
                    category: category
                )
            }

            errorMessage = ""
            return true
        } catch {
            errorMessage = "Unable to save book: \(error.localizedDescription)"
            return false
        }
    }

    func deleteBook() -> Bool {
        guard let book else {
            errorMessage = "No book was selected."
            return false
        }

        do {
            try persistenceService.deleteBook(book: book)
            errorMessage = ""
            return true
        } catch {
            errorMessage = "Unable to delete book: \(error.localizedDescription)"
            return false
        }
    }
}

