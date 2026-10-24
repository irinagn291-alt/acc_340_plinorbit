import Foundation

/// Three-star diagram for the chapter. Slots light as the spark collects them.
struct StarDiagram {
    private(set) var slots: [Bool]

    init(count: Int = 3) {
        slots = Array(repeating: false, count: max(1, count))
    }

    var lit: Int {
        slots.reduce(into: 0) { partial, slot in
            if slot { partial += 1 }
        }
    }

    var goal: Int { slots.count }

    var cleared: Bool { lit == slots.count }

    mutating func reset() {
        slots = Array(repeating: false, count: slots.count)
    }

    mutating func lightNext() {
        guard let index = slots.firstIndex(of: false) else { return }
        slots[index] = true
    }
}
