import Foundation

struct RunRecord: Codable, Equatable {
    var bestScore: Int
    var highestChapter: Int
    var diagramClears: [Int: Int]
    var lastPlayedDayKey: Int

    static let empty = RunRecord(
        bestScore: 0,
        highestChapter: 1,
        diagramClears: [:],
        lastPlayedDayKey: 0
    )
}

struct DemoState: Codable, Equatable {
    var chapter: Int
    var onboardingComplete: Bool
}

enum DayKey {
    static func today(date: Date = Date(), calendar: Calendar = .current) -> Int {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        let year = parts.year ?? 0
        let month = parts.month ?? 0
        let day = parts.day ?? 0
        return year * 10_000 + month * 100 + day
    }
}
