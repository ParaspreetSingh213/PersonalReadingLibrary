
import Foundation
import SwiftData

@Model
final class Book {
    var title: String
    var author: String
    var totalPages: Int
    var pagesRead: Int
    var dateAdded: Date
    var category: Category

    init(
        title: String,
        author: String,
        totalPages: Int,
        pagesRead: Int = 0,
        category: Category
    ) {
        self.title = title
        self.author = author
        self.totalPages = totalPages
        self.pagesRead = pagesRead
        self.dateAdded = Date()
        self.category = category
    }
}

