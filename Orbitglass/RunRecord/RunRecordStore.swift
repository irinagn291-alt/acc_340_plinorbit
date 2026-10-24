import Foundation

/// One `RunRecord` under `ogb.runrecord.v1`. Writes are debounced and stay off the frame loop.
final class RunRecordStore: @unchecked Sendable {
    static let storageKey = "ogb.runrecord.v1"
    static let demoKey = "ogb.demo.v1"
    static let shared = RunRecordStore()

    private let defaults: UserDefaults
    private let debounce: TimeInterval
    private var work: DispatchWorkItem?
    private(set) var record: RunRecord

    init(defaults: UserDefaults = .standard, debounce: TimeInterval = 0.35) {
        self.defaults = defaults
        self.debounce = debounce
        if let data = defaults.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode(RunRecord.self, from: data) {
            record = decoded
        } else {
            record = .empty
        }
    }

    func note(score: Int, chapter: Int, clears: [Int: Int]) {
        if score > record.bestScore {
            record.bestScore = score
        }
        if chapter > record.highestChapter {
            record.highestChapter = chapter
        }
        for (key, value) in clears {
            record.diagramClears[key] = max(record.diagramClears[key] ?? 0, value)
        }
        record.lastPlayedDayKey = DayKey.today()
        scheduleSave()
    }

    func resetAllData() {
        work?.cancel()
        work = nil
        defaults.removeObject(forKey: Self.storageKey)
        defaults.removeObject(forKey: Self.demoKey)
        record = .empty
        write()
    }

    func seedDemoIfNeeded() {
        #if targetEnvironment(simulator)
        guard defaults.object(forKey: Self.demoKey) == nil else { return }
        let seed = DemoState(chapter: 1, onboardingComplete: true)
        if let data = try? JSONEncoder().encode(seed) {
            defaults.set(data, forKey: Self.demoKey)
        }
        if defaults.object(forKey: Self.storageKey) == nil {
            record = RunRecord(
                bestScore: 0,
                highestChapter: 1,
                diagramClears: [:],
                lastPlayedDayKey: DayKey.today()
            )
            write()
        }
        #endif
    }

    func flush() {
        work?.cancel()
        work = nil
        write()
    }

    private func scheduleSave() {
        work?.cancel()
        if debounce <= 0 {
            write()
            return
        }
        let item = DispatchWorkItem { [weak self] in
            self?.write()
        }
        work = item
        DispatchQueue.main.asyncAfter(deadline: .now() + debounce, execute: item)
    }

    private func write() {
        guard let data = try? JSONEncoder().encode(record) else { return }
        defaults.set(data, forKey: Self.storageKey)
    }
}
