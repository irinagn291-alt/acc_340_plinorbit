import SpriteKit
import UIKit

final class PinNode: SKShapeNode {
    let mark = SKShapeNode(circleOfRadius: 3.5)

    override init() {
        super.init()
        let radius: CGFloat = 9
        path = CGPath(ellipseIn: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2), transform: nil)
        fillColor = DesignTokens.groundUI
        strokeColor = DesignTokens.inkUI.withAlphaComponent(0.4)
        lineWidth = 2
        name = "peg"
        zPosition = 10
        mark.fillColor = DesignTokens.heroUI.withAlphaComponent(0.85)
        mark.strokeColor = .clear
        mark.position = CGPoint(x: -2, y: 2)
        mark.zPosition = 11
        addChild(mark)

        let body = SKPhysicsBody(circleOfRadius: radius)
        body.isDynamic = false
        body.affectedByGravity = false
        body.categoryBitMask = PhysicsKind.peg
        body.contactTestBitMask = PhysicsKind.ball
        body.collisionBitMask = 0
        physicsBody = body
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func tint(chapter: Int) {
        switch chapter {
        case 2:
            strokeColor = DesignTokens.accentUI.withAlphaComponent(0.75)
        case 3:
            strokeColor = DesignTokens.weatherUI.withAlphaComponent(0.85)
        case 4:
            strokeColor = DesignTokens.collectibleUI
        default:
            strokeColor = DesignTokens.inkUI.withAlphaComponent(0.4)
        }
    }
}
