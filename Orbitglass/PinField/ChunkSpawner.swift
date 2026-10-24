import Foundation

struct PocketLane {
    var index: Int
    var dead: Bool
}

struct PinLayout {
    struct Star {
        var id: Int
        var x: Double
        var y: Double
        var required: Bool
        var taken: Bool
    }

    struct Peg {
        var x: Double
        var y: Double
        var radius: Double
    }

    struct Gate {
        var x: Double
        var y: Double
        var postRadius: Double
    }

    var pegGap: Double
    var stars: [Star]
    var pegs: [Peg]
    var pockets: [PocketLane]
    var gates: [Gate]
    var accepted: Bool

    static let empty = PinLayout(
        pegGap: 0,
        stars: [],
        pegs: [],
        pockets: [],
        gates: [],
        accepted: false
    )
}

/// Builds a chunk inside the live envelope and refuses a beat the ball cannot clear.
enum ChunkSpawner {
    static let columns = [70.0, 140.0, 220.0, 290.0]

    static func reachable(pegGap: Double, restitution: Double) -> Bool {
        Envelope.reachable(pegGap: pegGap, restitution: restitution)
    }

    static func lane(for x: Double) -> Int {
        let width = GameSimulation.boardWidth / Double(RestitutionCut.pocketCount)
        let raw = Int((x / width).rounded(.down))
        return min(max(raw, 0), RestitutionCut.pocketCount - 1)
    }

    static func opening(seed: UInt64) -> PinLayout? {
        spawn(
            seed: seed,
            chapter: 1,
            restitution: RestitutionCut.base,
            requiredGap: nil,
            window: Envelope.fairWindow
        )
    }

    static func spawn(
        seed: UInt64,
        chapter: Int,
        restitution: Double,
        requiredGap: Double?,
        window: Double
    ) -> PinLayout? {
        let natural = min(56.0, Envelope.regained(restitution: restitution) * 0.90)
        let gap = requiredGap ?? natural
        if Envelope.refuses(pegGap: gap, window: window, pocketDead: false, restitution: restitution) {
            return nil
        }
        var layout = makeCenter(seed: seed, chapter: chapter, gap: gap)
        layout.accepted = accepts(layout, restitution: restitution)
        if !layout.accepted { return nil }
        return layout
    }

    /// Required stars sit on a dead pocket. The spawner must not install this beat.
    static func impossiblePocket(seed: UInt64) -> PinLayout {
        var layout = makeCenter(seed: seed, chapter: 1, gap: 52)
        if layout.pockets.count > 2 {
            layout.pockets[2].dead = true
        }
        layout.accepted = false
        return layout
    }

    static func accepts(_ layout: PinLayout, restitution: Double) -> Bool {
        guard layout.pockets.count == RestitutionCut.pocketCount else { return false }
        guard layout.pockets.contains(where: { !$0.dead }) else { return false }
        guard reachable(pegGap: layout.pegGap, restitution: restitution) else { return false }
        for star in layout.stars where star.required {
            let lane = lane(for: star.x)
            if layout.pockets[lane].dead { return false }
        }
        return true
    }

    private static func makeCenter(seed: UInt64, chapter: Int, gap: Double) -> PinLayout {
        let nudge = Double(Int(seed % 5)) - 2
        var pegs: [PinLayout.Peg] = []
        var rowY = 560.0
        while rowY >= 150, pegs.count + columns.count <= NodeBudget.pins {
            for column in columns {
                pegs.append(PinLayout.Peg(x: column + nudge, y: rowY, radius: 9))
            }
            rowY -= max(gap, 52)
        }
        let stars = [
            PinLayout.Star(id: chapter * 10 + 1, x: 180, y: 510, required: true, taken: false),
            PinLayout.Star(id: chapter * 10 + 2, x: 180, y: 370, required: true, taken: false),
            PinLayout.Star(id: chapter * 10 + 3, x: 180, y: 230, required: true, taken: false),
        ]
        let pockets = (0..<RestitutionCut.pocketCount).map { index in
            PocketLane(index: index, dead: index == 0 || index == 4)
        }
        let gates = [
            PinLayout.Gate(x: 138, y: 160, postRadius: 8),
            PinLayout.Gate(x: 222, y: 160, postRadius: 8),
        ]
        return PinLayout(
            pegGap: gap,
            stars: stars,
            pegs: pegs,
            pockets: pockets,
            gates: gates,
            accepted: true
        )
    }
}
