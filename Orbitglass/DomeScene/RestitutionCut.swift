import Foundation

/// Published drop contract. A tilted bounce is `restitution * (1 - tradeoffDelta)`.
enum RestitutionCut {
    static let base = 0.72
    static let tradeoffDelta = 0.20
    static let pocketCount = 5
    static let chapterCount = 4

    static var tilted: Double {
        Envelope.tiltedRestitution(restitution: base, tradeoffDelta: tradeoffDelta)
    }
}

enum BoardTilt {
    static let maxAngle = 0.26
    static let aimSpeed = 460.0
    static let lip = 110.0
}

/// Reach envelopes from the domain contract. The drop uses restitution.
enum Envelope {
    static let gravity = 1600.0
    static let sampleFall = 120.0
    static let minWindow = 90.0
    static let fairWindow = 180.0

    static func regained(restitution: Double, fall: Double = sampleFall) -> Double {
        restitution * restitution * fall
    }

    static func reachable(pegGap: Double, restitution: Double, fall: Double = sampleFall) -> Bool {
        regained(restitution: restitution, fall: fall) + 0.000_001 >= pegGap
    }

    static func tiltedRestitution(restitution: Double, tradeoffDelta: Double) -> Double {
        restitution * (1 - tradeoffDelta)
    }

    static func nextWindow(window: Double, minWindow: Double, tradeoffDelta: Double) -> Double {
        max(minWindow, window * (1 - tradeoffDelta))
    }

    static func runnerReach(runSpeed: Double, jumpVelocity: Double, gravity: Double) -> Double {
        runSpeed * (2 * jumpVelocity / gravity) * 0.85
    }

    static func heavyJump(jumpVelocity: Double, tradeoffDelta: Double) -> Double {
        jumpVelocity * (1 - tradeoffDelta)
    }

    static func loadedLift(lift: Double, tradeoffDelta: Double) -> Double {
        lift * (1 - tradeoffDelta)
    }

    /// A beat outside the current envelope is refused: gap, window, or dead pocket.
    static func refuses(pegGap: Double, window: Double, pocketDead: Bool, restitution: Double) -> Bool {
        if pocketDead { return true }
        if window < minWindow { return true }
        let tightened = nextWindow(window: window, minWindow: minWindow, tradeoffDelta: RestitutionCut.tradeoffDelta)
        if tightened < minWindow { return true }
        if !reachable(pegGap: pegGap, restitution: restitution) { return true }
        let lift = loadedLift(lift: 420, tradeoffDelta: RestitutionCut.tradeoffDelta)
        if lift <= 0 { return true }
        let reach = runnerReach(runSpeed: 280, jumpVelocity: heavyJump(jumpVelocity: 900, tradeoffDelta: 0), gravity: 2200)
        if reach <= 0 { return true }
        return false
    }
}
