import Foundation
import Observation
import SwiftData

enum LibrarySortOption: String, CaseIterable, Identifiable {
    case title = "Title A–Z"
    case newest = "Newest First"

    var id: String {
        rawValue
    }
}

@MainActor
@Observable
final class LibraryViewModel {
    var books: [Book] = []
    var categories: [Category] = []

    var searchText = ""
    var selectedCategoryID: PersistentIdentifier?
    var selectedStatus = "All Statuses"
    var sortOption: LibrarySortOption = .title

    var errorMessage = ""

    private let persistenceService: PersistenceService

    init(persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
    }

    var filteredBooks: [Book] {
        let matchingBooks = books.filter { book in
            let matchesSearch =
                searchText.isEmpty ||
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText)

            let matchesCategory =
                selectedCategoryID == nil ||
                book.category.persistentModelID == selectedCategoryID

            let status = ReadingService.getStatus(
                pagesRead: book.pagesRead,
                totalPages: book.totalPages
            )

            let matchesStatus =
                selectedStatus == "All Statuses" ||
                status.rawValue == selectedStatus

            return matchesSearch && matchesCategory && matchesStatus
        }

        switch sortOption {
        case .title:
            return matchingBooks.sorted {
                $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }

        case .newest:
            return matchingBooks.sorted {
                $0.dateAdded > $1.dateAdded
            }
        }
    }

    func loadBooks() {
        do {
            books = try persistenceService.fetchBooks()
            categories = try persistenceService.fetchCategories()

            if let selectedCategoryID,
               !categories.contains(where: {
                   $0.persistentModelID == selectedCategoryID
               }) {
                self.selectedCategoryID = nil
            }

            errorMessage = ""
        } catch {
            errorMessage = "Unable to load library: \(error.localizedDescription)"
        }
    }
}
