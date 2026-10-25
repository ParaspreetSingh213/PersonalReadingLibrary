
import Foundation
import Observation

@MainActor
@Observable
final class LibraryViewModel {
    var books: [Book] = []
    var errorMessage = ""

    private let persistenceService: PersistenceService

    init(persistenceService: PersistenceService) {
        self.persistenceService = persistenceService
    }

    func loadBooks() {
        do {
            books = try persistenceService.fetchBooks()
            errorMessage = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

