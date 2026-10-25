import Foundation

enum ReadingStatus: String, CaseIterable {
    case notStarted = "Not Started"
    case reading = "Reading"
    case completed = "Completed"
}

struct ReadingService {

    static func getStatus(pagesRead: Int, totalPages: Int) -> ReadingStatus {
        if pagesRead == 0 {
            return .notStarted
        } else if pagesRead >= totalPages && totalPages > 0 {
            return .completed
        } else {
            return .reading
        }
    }

    static func getProgressPercentage(pagesRead: Int, totalPages: Int) -> Int {
        guard totalPages > 0 else {
            return 0
        }

        let percentage = (Double(pagesRead) / Double(totalPages)) * 100
        return Int(percentage.rounded())
    }

    static func getProgress(pagesRead: Int, totalPages: Int) -> Double {
        guard totalPages > 0 else {
            return 0
        }

        return Double(pagesRead) / Double(totalPages)
    }
}

