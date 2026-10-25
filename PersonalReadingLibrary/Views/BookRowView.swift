 
import SwiftUI

struct BookRowView: View {
    let book: Book

    var body: some View {
        let status = ReadingService.getStatus(
            pagesRead: book.pagesRead,
            totalPages: book.totalPages
        )

        let progress = ReadingService.getProgress(
            pagesRead: book.pagesRead,
            totalPages: book.totalPages
        )

        let percentage = ReadingService.getProgressPercentage(
            pagesRead: book.pagesRead,
            totalPages: book.totalPages
        )

        VStack(alignment: .leading, spacing: 10) {
            Text(book.title)
                .font(.headline)

            Text("By \(book.author)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack {
                Text(book.category.name)
                    .font(.caption)
                    .foregroundStyle(.blue)

                Spacer()

                Text(status.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: progress)

            HStack {
                Text("\(book.pagesRead) / \(book.totalPages) pages")

                Spacer()

                Text("\(percentage)%")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 6)
    }
}

