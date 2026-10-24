import Foundation

struct SparkBall {
    var x: Double
    var y: Double
    var vx: Double
    var vy: Double
    var radius: Double
    var resting: Bool
    var freefall: Bool

    static var resting: SparkBall {
        SparkBall(
            x: GameSimulation.boardWidth / 2,
            y: GameSimulation.startY,
            vx: 0,
            vy: 0,
            radius: 11,
            resting: true,
            freefall: false
        )
    }
}

/// Live node ceiling. Chunks recycle inside this pool. The scene does not allocate past it.
enum NodeBudget {
    static let cap = 400
    static let farLayers = 2
    static let props = 8
    static let pins = 36
    static let pinMarks = 36
    static let pockets = 5
    static let stars = 6
    static let gates = 4
    static let weather = 12
    static let puffs = 6
    static let heroParts = 9
    static let diagram = 4
    static let camera = 1
    static let field = 1
    static let lip = 1

    static var total: Int {
        farLayers + props + pins + pinMarks + pockets + stars + gates
            + weather + puffs + heroParts + diagram + camera + field + lip
    }
}

/// Drop-board simulation. The scene copies this state. Tests step the same type.
struct GameSimulation {
    static let fixedSeed: UInt64 = 20261024
    static let boardWidth = 360.0
    static let chunkHeight = 680.0
    static let pocketLine = 52.0
    static let startY = 630.0
    static let gravity = 1600.0
    static let collectRadius = 32.0

    private(set) var seed: UInt64
    private(set) var ball: SparkBall
    private(set) var layout: PinLayout
    private(set) var boardAngle = 0.0
    private(set) var aimAngle = 0.0
    private(set) var holding = false
    private(set) var holdRefused = false
    private(set) var nextBounceRestitution = RestitutionCut.base
    private(set) var restitutionArmed = false
    private(set) var chapter = 1
    private(set) var chunkInChapter = 0
    private(set) var clearedChunks = 0
    private(set) var runScore = 0
    private(set) var failed = false
    private(set) var diagram = StarDiagram()
    private(set) var diagramClears: [Int: Int] = [:]
    private(set) var airLift = 0.0
    private(set) var bouncedThisStep = false
    private(set) var collectedThisStep = false
    private(set) var highestReached = 1
    private(set) var reviewPose: String?
    var halted = false

    private var contactY = GameSimulation.startY

    var nodeBudget: Int { NodeBudget.total }
    var litStars: Int { diagram.lit }

    init(seed: UInt64 = GameSimulation.fixedSeed) {
        self.seed = seed
        ball = .resting
        layout = ChunkSpawner.opening(seed: seed) ?? .empty
        if !layout.accepted {
            failed = true
        }
    }

    mutating func beginHold(aim: Double) {
        holdRefused = false
        if ball.freefall || failed {
            holdRefused = true
            return
        }
        holding = true
        aimAngle = min(BoardTilt.maxAngle, max(-BoardTilt.maxAngle, aim))
    }

    mutating func endHold() {
        holding = false
        release()
    }

    mutating func release() {
        guard ball.resting, !failed, !halted else { return }
        ball.resting = false
        ball.freefall = true
        holding = false
        ball.vx = sin(boardAngle) * BoardTilt.aimSpeed
        ball.vy = -30
        contactY = ball.y
        if abs(boardAngle) <= 0.04 {
            restitutionArmed = false
            nextBounceRestitution = RestitutionCut.base
        }
    }

    mutating func step(dt: Double) {
        guard dt > 0, !failed, !halted else { return }
        if ball.resting {
            guard holding else { return }
            boardAngle += (aimAngle - boardAngle) * min(1, dt * 6)
            let shifted = GameSimulation.boardWidth / 2 + sin(boardAngle) * BoardTilt.lip
            ball.x = min(max(shifted, ball.radius), GameSimulation.boardWidth - ball.radius)
            if abs(boardAngle) > 0.04 {
                nextBounceRestitution = RestitutionCut.tilted
                restitutionArmed = true
            }
            return
        }

        boardAngle += (0 - boardAngle) * min(1, dt * 4)
        let oldY = ball.y
        ball.vy -= GameSimulation.gravity * dt
        ball.x += ball.vx * dt
        ball.y += ball.vy * dt
        contain()
        resolvePegs()
        resolveGates()
        collectOverlaps()
        if oldY > GameSimulation.pocketLine && ball.y <= GameSimulation.pocketLine {
            resolvePocket()
        }
        if ball.vy > 40 {
            airLift = max(0, ball.y - contactY)
        } else if !bouncedThisStep {
            airLift *= 0.92
        }
    }

    mutating func resolveContact(nameA: String?, nameB: String?) {
        let names = [nameA, nameB]
        guard names.contains("ball") else { return }
        if names.contains("star") {
            collectNearestStar()
        }
        if names.contains("dead"), ball.y <= GameSimulation.pocketLine + 24 {
            let lane = ChunkSpawner.lane(for: ball.x)
            if layout.pockets.indices.contains(lane), layout.pockets[lane].dead {
                failRun()
            }
        }
    }

    mutating func consumeImpulses() -> (bounce: Bool, collect: Bool) {
        let result = (bouncedThisStep, collectedThisStep)
        bouncedThisStep = false
        collectedThisStep = false
        return result
    }

    mutating func reloadAfterFail() {
        failed = false
        halted = false
        runScore = 0
        clearedChunks = 0
        chunkInChapter = 0
        chapter = 1
        highestReached = 1
        diagramClears = [:]
        collectedThisStep = false
        bouncedThisStep = false
        holdRefused = false
        reviewPose = nil
        parkBall()
        if let opening = ChunkSpawner.opening(seed: seed), opening.accepted {
            layout = opening
            diagram.reset()
        }
    }

    mutating func freeze(pose: String) {
        reviewPose = pose
        halted = true
        failed = false
        diagram.reset()
        for index in layout.stars.indices {
            layout.stars[index].taken = false
        }
        parkBall()
        switch pose {
        case "aim":
            holding = true
            aimAngle = BoardTilt.maxAngle
            boardAngle = BoardTilt.maxAngle
            ball.x = GameSimulation.boardWidth / 2 + sin(boardAngle) * BoardTilt.lip
            nextBounceRestitution = RestitutionCut.tilted
            restitutionArmed = true
        case "bounce":
            ball.resting = false
            ball.freefall = true
            ball.x = 188
            ball.y = 420
            ball.vy = 220
            airLift = 78
            bouncedThisStep = true
        case "pocket":
            ball.resting = false
            ball.freefall = true
            ball.x = GameSimulation.boardWidth / 2
            ball.y = GameSimulation.pocketLine
            ball.vy = 0
            runScore = 55
            for index in layout.stars.indices {
                layout.stars[index].taken = true
                diagram.lightNext()
            }
        case "miss":
            // Gap between the left dead bowl and the next pocket. Zero speed so
            // the frozen still cannot fall off the bottom of the playfield.
            ball.resting = false
            ball.freefall = true
            ball.x = GameSimulation.boardWidth / Double(RestitutionCut.pocketCount)
            ball.y = GameSimulation.pocketLine
            ball.vx = 0
            ball.vy = 0
            airLift = 0
        case "fail":
            ball.resting = false
            ball.freefall = false
            ball.x = 24
            ball.y = GameSimulation.pocketLine
            failed = true
        case "chapter":
            chapter = min(RestitutionCut.chapterCount, max(2, chapter))
            highestReached = chapter
            runScore = 80
            for index in layout.stars.indices {
                layout.stars[index].taken = true
                diagram.lightNext()
            }
        default:
            break
        }
    }

    private mutating func contain() {
        if ball.x < ball.radius {
            ball.x = ball.radius
            ball.vx = 0
        } else if ball.x > GameSimulation.boardWidth - ball.radius {
            ball.x = GameSimulation.boardWidth - ball.radius
            ball.vx = 0
        }
    }

    private mutating func resolvePegs() {
        for peg in layout.pegs {
            let dx = ball.x - peg.x
            let dy = ball.y - peg.y
            let reach = ball.radius + peg.radius
            let distanceSquared = dx * dx + dy * dy
            guard distanceSquared < reach * reach, distanceSquared > 0.000_001 else { continue }
            let distance = sqrt(distanceSquared)
            let nx = dx / distance
            let ny = dy / distance
            let push = reach - distance
            ball.x += nx * push
            ball.y += ny * push
            bounce(nx: nx, ny: ny)
        }
    }

    private mutating func bounce(nx: Double, ny: Double) {
        let approach = ball.vx * nx + ball.vy * ny
        guard approach < 0 else { return }
        let restitution = restitutionArmed ? nextBounceRestitution : RestitutionCut.base
        restitutionArmed = false
        nextBounceRestitution = RestitutionCut.base
        let impulse = (1 + restitution) * approach
        ball.vx -= impulse * nx
        ball.vy -= impulse * ny
        bouncedThisStep = true
        contactY = ball.y
        airLift = 0
    }

    private mutating func resolveGates() {
        for gate in layout.gates {
            let dx = ball.x - gate.x
            let dy = ball.y - gate.y
            let reach = ball.radius + gate.postRadius
            let distanceSquared = dx * dx + dy * dy
            guard distanceSquared < reach * reach, distanceSquared > 0.000_001 else { continue }
            let distance = sqrt(distanceSquared)
            let nx = dx / distance
            let ny = dy / distance
            ball.x += nx * (reach - distance)
            ball.y += ny * (reach - distance)
            bounce(nx: nx, ny: ny)
        }
    }

    private mutating func collectOverlaps() {
        collectNearestStar()
    }

    private mutating func collectNearestStar() {
        var bestIndex: Int?
        var bestDistance = GameSimulation.collectRadius * GameSimulation.collectRadius
        for (index, star) in layout.stars.enumerated() where star.required && !star.taken {
            let dx = ball.x - star.x
            let dy = ball.y - star.y
            let distance = dx * dx + dy * dy
            if distance <= bestDistance {
                bestDistance = distance
                bestIndex = index
            }
        }
        guard let bestIndex else { return }
        layout.stars[bestIndex].taken = true
        diagram.lightNext()
        runScore += 10
        collectedThisStep = true
    }

    private mutating func resolvePocket() {
        let lane = ChunkSpawner.lane(for: ball.x)
        let dead = layout.pockets.indices.contains(lane) && layout.pockets[lane].dead
        let ready = layout.stars.allSatisfy { !$0.required || $0.taken }
        if dead || !ready {
            failRun()
            return
        }
        runScore += 25
        clearedChunks += 1
        diagramClears[chapter, default: 0] += 1
        chunkInChapter += 1
        if chunkInChapter >= 2 {
            chunkInChapter = 0
            if chapter < RestitutionCut.chapterCount {
                chapter += 1
                highestReached = max(highestReached, chapter)
            }
        }
        loadChunk(index: clearedChunks)
        parkBall()
    }

    private mutating func failRun() {
        guard !failed else { return }
        failed = true
        ball.vx = 0
        ball.vy = 0
        ball.freefall = false
    }

    private mutating func loadChunk(index: Int) {
        let nextSeed = seed &+ UInt64(index) &* 997
        let restitution = restitutionArmed ? nextBounceRestitution : RestitutionCut.base
        guard let next = ChunkSpawner.spawn(
            seed: nextSeed,
            chapter: chapter,
            restitution: restitution,
            requiredGap: nil,
            window: Envelope.fairWindow
        ) else {
            failed = true
            return
        }
        layout = next
        diagram.reset()
    }

    private mutating func parkBall() {
        ball = .resting
        boardAngle = 0
        aimAngle = 0
        holding = false
        restitutionArmed = false
        nextBounceRestitution = RestitutionCut.base
        airLift = 0
        contactY = GameSimulation.startY
    }
}
