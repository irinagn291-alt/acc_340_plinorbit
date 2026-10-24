import SpriteKit
import UIKit

final class PocketLaneNode: SKShapeNode {
    private(set) var dead = false

    override init() {
        super.init()
        path = PocketLaneNode.bowlPath()
        lineWidth = 2
        zPosition = 2
        let body = SKPhysicsBody(rectangleOf: CGSize(width: 48, height: 18), center: CGPoint(x: 0, y: 6))
        body.isDynamic = false
        body.affectedByGravity = false
        body.collisionBitMask = 0
        physicsBody = body
        configure(dead: false)
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func configure(dead: Bool) {
        self.dead = dead
        name = dead ? "dead" : "pocket"
        fillColor = dead ? DesignTokens.hazardUI : DesignTokens.collectibleUI
        strokeColor = dead ? DesignTokens.shadowUI : DesignTokens.inkUI.withAlphaComponent(0.45)
        physicsBody?.categoryBitMask = dead ? PhysicsKind.dead : PhysicsKind.pocket
        physicsBody?.contactTestBitMask = PhysicsKind.ball
    }

    private static func bowlPath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -28, y: 16))
        path.addQuadCurve(to: CGPoint(x: 28, y: 16), control: CGPoint(x: 0, y: -10))
        path.addLine(to: CGPoint(x: 22, y: 16))
        path.addQuadCurve(to: CGPoint(x: -22, y: 16), control: CGPoint(x: 0, y: -2))
        path.closeSubpath()
        return path
    }
}
