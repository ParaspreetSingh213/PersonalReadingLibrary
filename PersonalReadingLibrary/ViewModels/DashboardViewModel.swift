import Foundation
import Observation

@MainActor
@Observable
final class DashboardViewModel {
    var totalBooks = 0
    var completedBooks = 0
    var readingBooks = 0
    var errorMessage = ""

    private let persistenceService: PersistenceService

    init(persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
    }

    func loadDashboard() {
        do {
            let books = try persistenceService.fetchBooks()

            totalBooks = books.count

            completedBooks = books.filter { book in
                ReadingService.getStatus(
                    pagesRead: book.pagesRead,
                    totalPages: book.totalPages
                ) == .completed
            }.count

            readingBooks = books.filter { book in
                ReadingService.getStatus(
                    pagesRead: book.pagesRead,
                    totalPages: book.totalPages
                ) == .reading
            }.count

            errorMessage = ""
        } catch {
            errorMessage = "Unable to load dashboard: \(error.localizedDescription)"
        }
    }
}

