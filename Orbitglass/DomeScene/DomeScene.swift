import SpriteKit
import UIKit

@MainActor
protocol DomePresenting: AnyObject {
    func domeUpdated(score: Int, chapter: Int, lit: Int, goal: Int)
    func domeShowChapter(_ chapter: Int)
}

/// Planetarium dome. One scene for the whole run. Fail reloads this instance.
final class DomeScene: SKScene, @MainActor SKPhysicsContactDelegate {
    private(set) var simulation = GameSimulation(seed: GameSimulation.fixedSeed)
    weak var presenter: DomePresenting?
    var recordStore = RunRecordStore.shared

    private let cameraNode = SKCameraNode()
    private let field = SKNode()
    private let farNode = SKSpriteNode()
    private let midNode = SKSpriteNode()
    private let hero = HeroNode()
    private let lip = SKShapeNode(rectOf: CGSize(width: 168, height: 14), cornerRadius: 7)
    private let diagram = SKNode()
    private var diagramStars: [SKSpriteNode] = []
    private var pins: [PinNode] = []
    private var pockets: [PocketLaneNode] = []
    private var stars: [SKSpriteNode] = []
    private var gates: [SKShapeNode] = []
    private var propFar: [SKSpriteNode] = []
    private var propNear: [SKSpriteNode] = []
    private var weather: [SKShapeNode] = []
    private var weatherPhase: [CGFloat] = []
    private var puffs: [SKShapeNode] = []
    private let dust = LandingDust()
    private var contacts: [(String?, String?)] = []

    private var built = false
    private var reviewFrozen = false
    private var lastUpdateTime: TimeInterval = 0
    private var accumulator = 0.0
    private let fixedStep = 1.0 / 120.0
    private var hitStop: TimeInterval = 0
    private var trauma: CGFloat = 0
    private var cameraY: CGFloat = 0
    private var cameraReady = false
    private var limbPhase: CGFloat = 0
    private var squashX: CGFloat = 1
    private var squashY: CGFloat = 1
    private var laidOutSize = CGSize.zero
    private var announcedChapter = 1
    private var publishedScore = -1
    private var publishedChapter = -1
    private var publishedLit = -1
    private var reduceMotion = false

    override init() {
        super.init(size: CGSize(width: 390, height: 844))
        scaleMode = .resizeFill
        anchorPoint = .zero
        backgroundColor = DesignTokens.skyUI
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    override func didMove(to view: SKView) {
        reduceMotion = UIAccessibility.isReduceMotionEnabled
        DomeTone.shared.prepare()
        guard !built else { return }
        built = true
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        camera = cameraNode
        addChild(cameraNode)
        buildPools()
        placeField()
        renderSimulation()
        applyLaunchPose()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        contacts.append((contact.bodyA.node?.name, contact.bodyB.node?.name))
    }

    override func update(_ currentTime: TimeInterval) {
        let dt = lastUpdateTime == 0 ? 0 : min(currentTime - lastUpdateTime, 1.0 / 30.0)
        lastUpdateTime = currentTime
        reduceMotion = UIAccessibility.isReduceMotionEnabled
        if reviewFrozen {
            pinFrozenHero()
            return
        }
        if hitStop > 0 {
            hitStop -= dt
            return
        }
        if !simulation.halted {
            accumulator += dt
            var slices = 0
            while accumulator >= fixedStep && slices < 2 {
                simulation.step(dt: fixedStep)
                accumulator -= fixedStep
                slices += 1
            }
            if accumulator > fixedStep {
                accumulator = 0
            }
        }
        drainContacts()
        let impulse = simulation.consumeImpulses()
        if simulation.failed {
            DomeTone.shared.failGlass()
            showPuff(at: hero.position)
            dust.burst(at: hero.position, tint: DesignTokens.hazardUI, reduced: reduceMotion)
            recordStore.note(
                score: simulation.runScore,
                chapter: simulation.highestReached,
                clears: simulation.diagramClears
            )
            reloadScene()
            trauma = 0.85
        } else {
            if impulse.bounce || impulse.collect {
                squashX = impulse.bounce ? 1.28 : 0.86
                squashY = impulse.bounce ? 0.72 : 1.22
                showPuff(at: hero.position)
                let tint = impulse.collect ? DesignTokens.collectibleUI : DesignTokens.weatherUI
                dust.burst(at: hero.position, tint: tint, reduced: reduceMotion)
                if impulse.collect {
                    DomeTone.shared.collect()
                } else {
                    DomeTone.shared.bounce()
                }
                hitStop = 0.05
                trauma = min(1, trauma + (impulse.bounce ? 0.4 : 0.28))
            }
            if simulation.chapter != announcedChapter && simulation.clearedChunks > 0 {
                announcedChapter = simulation.chapter
                simulation.halted = true
                DomeTone.shared.chapterChime()
                recordStore.note(
                    score: simulation.runScore,
                    chapter: simulation.chapter,
                    clears: simulation.diagramClears
                )
                presenter?.domeShowChapter(simulation.chapter)
            }
        }
        easeSquash(dt: dt)
        limbPhase += CGFloat(dt) * 9
        renderSimulation()
        updateCamera(dt: dt)
        updateWeather(dt: dt)
        publish()
    }

    func reloadScene() {
        simulation.reloadAfterFail()
        announcedChapter = simulation.chapter
        hitStop = 0
        accumulator = 0
        placeField()
        renderSimulation()
    }

    func haltRun() {
        guard !reviewFrozen else { return }
        simulation.halted = true
    }

    func resumeRun() {
        guard !reviewFrozen else { return }
        simulation.halted = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !reviewFrozen, let touch = touches.first else { return }
        simulation.beginHold(aim: angle(forSceneX: touch.location(in: self).x))
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !reviewFrozen, let touch = touches.first else { return }
        simulation.beginHold(aim: angle(forSceneX: touch.location(in: self).x))
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !reviewFrozen else { return }
        let wasResting = simulation.ball.resting
        simulation.endHold()
        if wasResting && simulation.ball.freefall {
            DomeTone.shared.releaseTick()
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event)
    }

    private func applyLaunchPose() {
        guard let pose = ReviewLaunch.screen else { return }
        simulation.freeze(pose: pose)
        reviewFrozen = true
        announcedChapter = simulation.chapter
        placeField()
        renderSimulation()
        switch pose {
        case "bounce":
            squashX = 0.82
            squashY = 1.24
            showPuff(at: hero.position)
            dust.burst(at: hero.position, tint: DesignTokens.weatherUI, reduced: false)
        case "pocket":
            squashX = 1.2
            squashY = 0.74
            showPuff(at: hero.position)
            dust.burst(at: hero.position, tint: DesignTokens.collectibleUI, reduced: false)
        case "fail":
            squashX = 1.34
            squashY = 0.62
            showPuff(at: hero.position)
            dust.burst(at: hero.position, tint: DesignTokens.hazardUI, reduced: false)
            trauma = 1
        case "miss":
            squashX = 0.7
            squashY = 1.48
        default:
            break
        }
        let rigVelocity: CGVector
        if pose == "miss" {
            rigVelocity = CGVector(dx: 0, dy: -140)
        } else {
            rigVelocity = CGVector(dx: simulation.ball.vx, dy: simulation.ball.vy)
        }
        hero.updateRig(
            velocity: rigVelocity,
            lift: CGFloat(simulation.airLift),
            phase: pose == "bounce" || pose == "miss" ? 1.2 : 0,
            squashX: squashX,
            squashY: squashY,
            hazard: pose == "fail",
            armed: simulation.restitutionArmed || pose == "aim"
        )
        if pose == "miss" {
            hero.body.strokeColor = DesignTokens.hazardUI
            hero.body.lineWidth = 3.5
            hero.costArc.isHidden = false
            hero.costArc.strokeColor = DesignTokens.hazardUI
            hero.costArc.lineWidth = 4
            hero.costArc.xScale = squashX
            hero.costArc.yScale = squashY
        }
        pinFrozenHero()
        updateCamera(dt: 0)
        publish()
    }

    /// Still of the orb falling through the gap: ghost trail above, sparks on the rims.
    private func stageMissSlip() {
        let origin = hero.position
        for (index, puff) in puffs.prefix(4).enumerated() {
            puff.removeAllActions()
            puff.isHidden = false
            let rise = CGFloat(index + 1) * 36
            puff.position = CGPoint(x: origin.x, y: origin.y + rise)
            let scale = 1.85 - CGFloat(index) * 0.32
            puff.xScale = scale * 0.68
            puff.yScale = scale * 1.2
            puff.alpha = 0.62 - CGFloat(index) * 0.1
            puff.fillColor = index == 0
                ? DesignTokens.hazardUI.withAlphaComponent(0.95)
                : DesignTokens.heroUI.withAlphaComponent(0.9)
            puff.zPosition = 18
        }
        let sparkOffsets: [CGFloat] = [-30, 30]
        for (puff, dx) in zip(puffs.dropFirst(4), sparkOffsets) {
            puff.removeAllActions()
            puff.isHidden = false
            puff.position = CGPoint(x: origin.x + dx, y: origin.y - 14)
            puff.xScale = 1.35
            puff.yScale = 0.48
            puff.alpha = 1
            puff.fillColor = DesignTokens.hazardUI
            puff.zPosition = 36
        }
        for index in [0, 1] where pockets.indices.contains(index) {
            pockets[index].lineWidth = 4
            pockets[index].strokeColor = DesignTokens.hazardUI
        }
    }

    private func pinFrozenHero() {
        hero.position = scenePoint(simulation.ball.x, simulation.ball.y)
        hero.physicsBody?.velocity = .zero
        hero.physicsBody?.angularVelocity = 0
        hero.physicsBody?.isDynamic = false
        if simulation.reviewPose == "miss" {
            stageMissSlip()
        }
    }

    private func buildPools() {
        farNode.zPosition = 0
        midNode.zPosition = 2
        addChild(farNode)
        addChild(midNode)

        field.zPosition = 8
        addChild(field)

        lip.fillColor = DesignTokens.groundUI
        lip.strokeColor = DesignTokens.accentUI
        lip.lineWidth = 2
        lip.zPosition = 13
        lip.name = "lip"
        field.addChild(lip)

        for _ in 0..<NodeBudget.pins {
            let pin = PinNode()
            pins.append(pin)
            field.addChild(pin)
        }
        for _ in 0..<NodeBudget.pockets {
            let pocket = PocketLaneNode()
            pockets.append(pocket)
            field.addChild(pocket)
        }
        for _ in 0..<NodeBudget.stars {
            let star = WorldArt.sprite(stem: WorldArt.collectible, size: CGSize(width: 28, height: 28))
            star.name = "star"
            star.zPosition = 12
            let body = SKPhysicsBody(circleOfRadius: 12)
            body.isDynamic = false
            body.affectedByGravity = false
            body.categoryBitMask = PhysicsKind.star
            body.contactTestBitMask = PhysicsKind.ball
            body.collisionBitMask = 0
            star.physicsBody = body
            stars.append(star)
            field.addChild(star)
        }
        for _ in 0..<NodeBudget.gates {
            let post = SKShapeNode(circleOfRadius: 8)
            post.fillColor = DesignTokens.midUI
            post.strokeColor = DesignTokens.inkUI.withAlphaComponent(0.3)
            post.lineWidth = 1.5
            post.name = "gate"
            post.zPosition = 11
            gates.append(post)
            field.addChild(post)
        }
        for index in 0..<NodeBudget.props {
            let stem = index < 4 ? WorldArt.propFar : WorldArt.propNear
            let side = CGFloat(index.isMultiple(of: 2) ? -1 : 1)
            let node = WorldArt.sprite(stem: stem, size: CGSize(width: 54, height: 72))
            node.zPosition = index < 4 ? 3 : 14
            node.position = CGPoint(x: side * 150, y: 180 + CGFloat(index) * 90)
            if index < 4 {
                propFar.append(node)
            } else {
                propNear.append(node)
            }
            addChild(node)
        }

        hero.zPosition = 20
        addChild(hero)

        diagram.zPosition = 30
        for index in 0..<3 {
            let mark = WorldArt.sprite(stem: WorldArt.collectible, size: CGSize(width: 18, height: 18))
            mark.position = CGPoint(x: CGFloat(index - 1) * 26, y: 0)
            mark.zPosition = 31
            diagramStars.append(mark)
            diagram.addChild(mark)
        }
        addChild(diagram)

        for index in 0..<NodeBudget.puffs {
            let puff = SKShapeNode(circleOfRadius: 8)
            puff.name = "puff"
            puff.fillColor = DesignTokens.weatherUI.withAlphaComponent(0.85)
            puff.strokeColor = .clear
            puff.zPosition = 34
            puff.isHidden = true
            puff.position = CGPoint(x: -800, y: -800 + CGFloat(index))
            puffs.append(puff)
            addChild(puff)
        }
        for index in 0..<NodeBudget.weather {
            let flake = SKShapeNode(circleOfRadius: index.isMultiple(of: 3) ? 2.4 : 1.6)
            flake.fillColor = DesignTokens.weatherUI.withAlphaComponent(0.75)
            flake.strokeColor = .clear
            flake.zPosition = 40
            flake.name = "weather"
            weather.append(flake)
            weatherPhase.append(CGFloat(index) * 0.7)
            addChild(flake)
        }
        dust.attach(to: self)
    }

    private func placeField() {
        let scale = boardScale()
        let armed = simulation.restitutionArmed
        for (index, pin) in pins.enumerated() {
            pin.tint(chapter: simulation.chapter)
            if index < simulation.layout.pegs.count {
                let peg = simulation.layout.pegs[index]
                pin.isHidden = false
                pin.position = scenePoint(peg.x, peg.y)
                pin.physicsBody?.categoryBitMask = PhysicsKind.peg
            } else {
                park(pin)
            }
        }
        let laneWidth = GameSimulation.boardWidth / Double(RestitutionCut.pocketCount)
        for (index, pocket) in pockets.enumerated() {
            if index < simulation.layout.pockets.count {
                let lane = simulation.layout.pockets[index]
                pocket.isHidden = false
                pocket.configure(dead: lane.dead)
                pocket.position = scenePoint(laneWidth * (Double(index) + 0.5), 28)
                pocket.xScale = scale
                pocket.yScale = scale
            } else {
                park(pocket)
            }
        }
        for (index, star) in stars.enumerated() {
            if index < simulation.layout.stars.count {
                let item = simulation.layout.stars[index]
                star.isHidden = false
                star.position = scenePoint(item.x, item.y)
                star.alpha = item.taken ? 0.25 : 1
                let starScale: CGFloat = armed && !item.taken ? 0.78 : 1
                star.xScale = starScale
                star.yScale = starScale
                star.physicsBody?.categoryBitMask = item.taken ? 0 : PhysicsKind.star
            } else {
                park(star)
            }
        }
        for (index, post) in gates.enumerated() {
            if index < simulation.layout.gates.count {
                let gate = simulation.layout.gates[index]
                post.isHidden = false
                post.position = scenePoint(gate.x, gate.y)
            } else {
                park(post)
            }
        }
        lip.position = scenePoint(GameSimulation.boardWidth / 2, GameSimulation.startY + 18)
        lip.zRotation = CGFloat(simulation.boardAngle)
        lip.xScale = scale
        lip.strokeColor = armed ? DesignTokens.hazardUI : DesignTokens.accentUI
        lip.lineWidth = armed ? 3 : 2
    }

    private func renderSimulation() {
        layoutPlatesIfNeeded()
        placeField()
        let ball = simulation.ball
        hero.position = scenePoint(ball.x, ball.y)
        if reviewFrozen {
            hero.physicsBody?.velocity = .zero
            hero.physicsBody?.angularVelocity = 0
            hero.physicsBody?.isDynamic = false
        } else {
            hero.physicsBody?.isDynamic = true
            hero.physicsBody?.velocity = CGVector(dx: ball.vx, dy: ball.vy)
        }
        let hazard = simulation.reviewPose == "fail" || (simulation.failed && !reviewFrozen)
        hero.updateRig(
            velocity: CGVector(dx: ball.vx, dy: ball.vy),
            lift: CGFloat(simulation.airLift) * boardScale(),
            phase: limbPhase,
            squashX: squashX,
            squashY: squashY,
            hazard: hazard,
            armed: simulation.restitutionArmed
        )
        for (index, mark) in diagramStars.enumerated() {
            let lit = index < simulation.diagram.slots.count && simulation.diagram.slots[index]
            mark.alpha = lit ? 1 : 0.28
            mark.setScale(lit ? 1.15 : 0.85)
        }
        let parallaxBase = cameraReady ? cameraY : size.height * 0.5
        farNode.position = CGPoint(
            x: size.width * 0.5 - (parallaxBase - size.height * 0.5) * 0.08,
            y: parallaxBase - (parallaxBase - size.height * 0.45) * 0.22
        )
        midNode.position = CGPoint(
            x: size.width * 0.5 - (parallaxBase - size.height * 0.5) * 0.16,
            y: parallaxBase - (parallaxBase - size.height * 0.42) * 0.38
        )
        for (index, prop) in propFar.enumerated() {
            let column: CGFloat = index.isMultiple(of: 2) ? 36 : size.width - 36
            prop.position = CGPoint(x: column, y: 160 + CGFloat(index) * 120 + parallaxBase * 0.18)
            prop.zPosition = 3
        }
        for (index, prop) in propNear.enumerated() {
            let column: CGFloat = index.isMultiple(of: 2) ? 28 : size.width - 28
            prop.position = CGPoint(x: column, y: 90 + CGFloat(index) * 150)
            prop.zPosition = 14
        }
    }

    private func updateCamera(dt: TimeInterval) {
        let ball = scenePoint(simulation.ball.x, simulation.ball.y)
        let lead = max(-28, min(28, CGFloat(simulation.ball.vy) * 0.03 * boardScale()))
        var target = ball.y + lead
        let half = size.height * 0.5
        let top = scenePoint(0, GameSimulation.chunkHeight).y
        let lower = half
        let upper = max(half, top - half)
        target = min(max(target, lower), upper)
        if !cameraReady || dt == 0 {
            cameraY = target
            cameraReady = true
        } else {
            cameraY += (target - cameraY) * min(1, CGFloat(dt) * 7)
        }
        var originX = ball.x
        let midX = scenePoint(GameSimulation.boardWidth / 2, 0).x
        originX += (midX - originX) * 0.82
        if trauma > 0 {
            if !reduceMotion {
                let signX: CGFloat = Bool.random() ? 1 : -1
                let signY: CGFloat = Bool.random() ? 1 : -1
                let magnitude = trauma * trauma * 5
                originX += signX * magnitude
                cameraY += signY * magnitude
            }
            trauma = max(0, trauma - CGFloat(dt) * 1.8)
        }
        cameraNode.position = CGPoint(x: originX, y: cameraY)
        diagram.position = CGPoint(x: cameraNode.position.x, y: cameraNode.position.y + size.height * 0.5 - 108)
    }

    private func updateWeather(dt: TimeInterval) {
        guard size.width > 1 else { return }
        let span = size.height
        let visibleFlakes = 3 + simulation.chapter * 2
        for index in weather.indices {
            weather[index].isHidden = index >= visibleFlakes
            weatherPhase[index] += CGFloat(dt) * (0.35 + CGFloat(index % 4) * 0.12)
            let lane = CGFloat(index) / CGFloat(max(weather.count, 1))
            let x = cameraNode.position.x - size.width * 0.48 + lane * size.width * 0.96 + sin(weatherPhase[index]) * 10
            var y = cameraNode.position.y - span * 0.45 + CGFloat(index * 37 % Int(max(span, 1)))
            y += CGFloat(dt) * 18
            if y > cameraNode.position.y + span * 0.5 {
                y -= span
            }
            weather[index].position = CGPoint(x: x, y: y)
            weather[index].zPosition = 40
        }
    }

    private func drainContacts() {
        let batch = contacts
        contacts.removeAll(keepingCapacity: true)
        for pair in batch {
            simulation.resolveContact(nameA: pair.0, nameB: pair.1)
        }
    }

    private func showPuff(at point: CGPoint) {
        guard let puff = puffs.first(where: { $0.action(forKey: "puff") == nil }) ?? puffs.first else { return }
        puff.isHidden = false
        puff.position = point
        puff.removeAllActions()
        if reviewFrozen {
            puff.alpha = 0.95
            puff.xScale = 1.35
            puff.yScale = 1.35
            return
        }
        puff.alpha = 0.9
        puff.xScale = 0.35
        puff.yScale = 0.35
        let grow = SKAction.scale(to: 1.4, duration: 0.18)
        let fade = SKAction.fadeOut(withDuration: 0.22)
        puff.run(SKAction.sequence([SKAction.group([grow, fade]), SKAction.hide()]), withKey: "puff")
    }

    private func easeSquash(dt: TimeInterval) {
        let blend = min(1, CGFloat(dt) * 10)
        squashX += (1 - squashX) * blend
        squashY += (1 - squashY) * blend
    }

    private func publish() {
        let score = simulation.runScore
        let chapter = simulation.chapter
        let lit = simulation.litStars
        guard score != publishedScore || chapter != publishedChapter || lit != publishedLit else { return }
        publishedScore = score
        publishedChapter = chapter
        publishedLit = lit
        presenter?.domeUpdated(score: score, chapter: chapter, lit: lit, goal: simulation.diagram.goal)
    }

    private func layoutPlatesIfNeeded() {
        guard size.width > 2, size != laidOutSize else { return }
        laidOutSize = size
        let plate = CGSize(width: size.width * 1.45, height: size.height * 1.45)
        farNode.texture = WorldArt.texture(stem: WorldArt.backdropFar, size: plate)
        farNode.size = plate
        farNode.zPosition = 0
        midNode.texture = WorldArt.texture(stem: WorldArt.backdropMid, size: plate)
        midNode.size = plate
        midNode.alpha = 0.55
        midNode.zPosition = 2
    }

    private func boardScale() -> CGFloat {
        guard size.width > 1 else { return 1 }
        return min(1, (size.width - 12) / CGFloat(GameSimulation.boardWidth))
    }

    private func scenePoint(_ x: Double, _ y: Double) -> CGPoint {
        let scale = boardScale()
        let drawn = CGFloat(GameSimulation.boardWidth) * scale
        let origin = (size.width - drawn) / 2
        return CGPoint(x: origin + CGFloat(x) * scale, y: CGFloat(y) * scale)
    }

    private func angle(forSceneX x: CGFloat) -> Double {
        let center = scenePoint(GameSimulation.boardWidth / 2, 0).x
        let span = max(48, size.width * 0.42)
        let raw = Double((x - center) / span) * BoardTilt.maxAngle
        return min(BoardTilt.maxAngle, max(-BoardTilt.maxAngle, raw))
    }

    private func park(_ node: SKNode) {
        node.isHidden = true
        node.position = CGPoint(x: -600, y: -600)
        node.physicsBody?.categoryBitMask = 0
    }
}
