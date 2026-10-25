
import Foundation
import SwiftData

@Model
final class Category {
    var name: String

    @Relationship(deleteRule: .deny, inverse: \Book.category)
    var books: [Book] = []

    init(name: String) {
        self.name = name
    }
}

