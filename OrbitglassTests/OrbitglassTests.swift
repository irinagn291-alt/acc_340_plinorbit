import XCTest
@testable import Orbitglass

final class OrbitglassTests: XCTestCase {
    func testFixedSeedClearsFirstChunks() {
        var simulation = GameSimulation(seed: GameSimulation.fixedSeed)
        XCTAssertTrue(simulation.layout.accepted)
        XCTAssertLessThanOrEqual(simulation.nodeBudget, 400)
        var steps = 0
        while simulation.clearedChunks < 2 && steps < 4000 && !simulation.failed {
            if simulation.ball.resting {
                simulation.release()
            }
            simulation.step(dt: 1.0 / 120.0)
            steps += 1
        }
        XCTAssertFalse(simulation.failed, "steps \(steps) y \(simulation.ball.y) lit \(simulation.litStars)")
        XCTAssertGreaterThanOrEqual(simulation.clearedChunks, 2)
        XCTAssertLessThanOrEqual(simulation.nodeBudget, NodeBudget.cap)
        XCTAssertEqual(simulation.nodeBudget, NodeBudget.total)
    }

    func testLightEnvelopeIsReachableAndLoadedIsStricter() {
        let gap = 52.0
        let light = RestitutionCut.base
        let loaded = RestitutionCut.tilted
        XCTAssertEqual(light, 0.72, accuracy: 0.000_001)
        XCTAssertEqual(loaded, 0.576, accuracy: 0.000_001)
        XCTAssertEqual(RestitutionCut.pocketCount, 5)
        XCTAssertTrue(ChunkSpawner.reachable(pegGap: gap, restitution: light))
        XCTAssertFalse(ChunkSpawner.reachable(pegGap: gap, restitution: loaded))
        XCTAssertGreaterThan(
            Envelope.regained(restitution: light),
            Envelope.regained(restitution: loaded)
        )
        let opening = ChunkSpawner.spawn(
            seed: GameSimulation.fixedSeed,
            chapter: 1,
            restitution: light,
            requiredGap: nil,
            window: Envelope.fairWindow
        )
        XCTAssertNotNil(opening)
        XCTAssertTrue(ChunkSpawner.reachable(pegGap: opening?.pegGap ?? 0, restitution: light))
    }

    func testRejectsImpossibleGapWindowOrPocket() {
        let blockedGap = ChunkSpawner.spawn(
            seed: GameSimulation.fixedSeed,
            chapter: 1,
            restitution: RestitutionCut.base,
            requiredGap: 200,
            window: Envelope.fairWindow
        )
        XCTAssertNil(blockedGap)
        XCTAssertFalse(ChunkSpawner.reachable(pegGap: 200, restitution: RestitutionCut.base))

        let blockedWindow = ChunkSpawner.spawn(
            seed: GameSimulation.fixedSeed,
            chapter: 1,
            restitution: RestitutionCut.base,
            requiredGap: nil,
            window: 40
        )
        XCTAssertNil(blockedWindow)

        let pocket = ChunkSpawner.impossiblePocket(seed: GameSimulation.fixedSeed)
        XCTAssertFalse(ChunkSpawner.accepts(pocket, restitution: RestitutionCut.base))
        XCTAssertTrue(Envelope.refuses(pegGap: 52, window: Envelope.fairWindow, pocketDead: true, restitution: RestitutionCut.base))
    }

    func testNodeBudgetStaysWithinCap() {
        var simulation = GameSimulation(seed: GameSimulation.fixedSeed)
        XCTAssertLessThanOrEqual(simulation.nodeBudget, 400)
        simulation.release()
        for _ in 0..<300 {
            simulation.step(dt: 1.0 / 120.0)
        }
        XCTAssertLessThanOrEqual(simulation.nodeBudget, 400)
        XCTAssertLessThanOrEqual(NodeBudget.total, NodeBudget.cap)
    }

    func testBestScoreRoundTrip() throws {
        let suite = "ogb-tests-\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suite))
        defaults.removePersistentDomain(forName: suite)
        let store = RunRecordStore(defaults: defaults, debounce: 0)
        store.note(score: 80, chapter: 2, clears: [1: 2])
        store.flush()
        let loaded = RunRecordStore(defaults: defaults, debounce: 0)
        XCTAssertEqual(loaded.record.bestScore, 80)
        XCTAssertEqual(loaded.record.highestChapter, 2)
        XCTAssertEqual(loaded.record.diagramClears[1], 2)
        XCTAssertEqual(loaded.record.lastPlayedDayKey, DayKey.today())
        store.resetAllData()
        XCTAssertEqual(store.record.bestScore, 0)
        defaults.removePersistentDomain(forName: suite)
    }

    func testReviewLaunchScreenParsesPose() {
        XCTAssertEqual(ReviewLaunch.screen(in: [ReviewLaunch.argument, "bounce"]), "bounce")
        XCTAssertEqual(ReviewLaunch.screen(in: [ReviewLaunch.argument, "pocket"]), "pocket")
        XCTAssertNil(ReviewLaunch.screen(in: ["Orbitglass"]))
        XCTAssertNil(ReviewLaunch.screen(in: [ReviewLaunch.argument]))
        _ = ReviewLaunch.screen
    }

    func testHoldDuringFreefallIsRefused() {
        var simulation = GameSimulation(seed: GameSimulation.fixedSeed)
        simulation.release()
        XCTAssertTrue(simulation.ball.freefall)
        let angle = simulation.boardAngle
        simulation.beginHold(aim: 0.2)
        XCTAssertTrue(simulation.holdRefused)
        XCTAssertEqual(simulation.boardAngle, angle, accuracy: 0.000_001)
        XCTAssertEqual(simulation.nextBounceRestitution, RestitutionCut.base, accuracy: 0.000_001)
        simulation.step(dt: 1.0 / 120.0)
        XCTAssertEqual(simulation.boardAngle, 0, accuracy: 0.000_001)
    }
}
