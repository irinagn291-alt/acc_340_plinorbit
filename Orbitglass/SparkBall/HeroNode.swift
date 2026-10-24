import SpriteKit
import UIKit

/// Articulated glass spark: body, limb, face, and a shadow that is not a child of the body.
final class HeroNode: SKNode {
    let shadow = SparkBallShadowNode()
    let body = SKShapeNode(circleOfRadius: 15)
    let highlight = SKShapeNode(ellipseOf: CGSize(width: 10, height: 7))
    let limb = SKShapeNode(rectOf: CGSize(width: 6, height: 16), cornerRadius: 3)
    let face = SKNode()
    let leftEye = SKShapeNode(circleOfRadius: 2.1)
    let rightEye = SKShapeNode(circleOfRadius: 2.1)
    let mouth = SKShapeNode()
    let costArc = SKShapeNode()

    override init() {
        super.init()
        name = "ball"
        zPosition = 20

        body.fillColor = DesignTokens.heroUI
        body.strokeColor = DesignTokens.accentUI
        body.lineWidth = 2.5
        body.zPosition = 21

        highlight.fillColor = UIColor.white.withAlphaComponent(0.82)
        highlight.strokeColor = .clear
        highlight.position = CGPoint(x: -4, y: 5)
        highlight.zPosition = 22

        limb.fillColor = DesignTokens.accentUI
        limb.strokeColor = DesignTokens.inkUI.withAlphaComponent(0.35)
        limb.lineWidth = 1
        limb.position = CGPoint(x: 13, y: -2)
        limb.zPosition = 21

        leftEye.fillColor = DesignTokens.shadowUI
        leftEye.strokeColor = .clear
        leftEye.position = CGPoint(x: -4.5, y: 1.5)
        rightEye.fillColor = DesignTokens.shadowUI
        rightEye.strokeColor = .clear
        rightEye.position = CGPoint(x: 4.5, y: 1.5)

        mouth.path = CGPath(ellipseIn: CGRect(x: -3, y: -6, width: 6, height: 3), transform: nil)
        mouth.fillColor = DesignTokens.accentUI
        mouth.strokeColor = .clear

        face.zPosition = 23
        face.addChild(leftEye)
        face.addChild(rightEye)
        face.addChild(mouth)

        body.addChild(highlight)
        body.addChild(limb)
        body.addChild(face)

        let arc = UIBezierPath(
            arcCenter: .zero,
            radius: 22,
            startAngle: .pi * 1.12,
            endAngle: .pi * 1.88,
            clockwise: true
        )
        costArc.path = arc.cgPath
        costArc.strokeColor = DesignTokens.hazardUI
        costArc.fillColor = .clear
        costArc.lineWidth = 2
        costArc.lineCap = .round
        costArc.isHidden = true
        costArc.zPosition = 24
        costArc.name = "costArc"

        addChild(shadow)
        addChild(body)
        addChild(costArc)

        let bodyPhysics = SKPhysicsBody(circleOfRadius: 11)
        bodyPhysics.isDynamic = true
        bodyPhysics.affectedByGravity = false
        bodyPhysics.allowsRotation = false
        bodyPhysics.linearDamping = 0
        bodyPhysics.angularDamping = 0
        bodyPhysics.friction = 0
        bodyPhysics.restitution = 0
        bodyPhysics.categoryBitMask = PhysicsKind.ball
        bodyPhysics.contactTestBitMask = PhysicsKind.peg | PhysicsKind.star | PhysicsKind.pocket | PhysicsKind.dead
        bodyPhysics.collisionBitMask = 0
        bodyPhysics.usesPreciseCollisionDetection = true
        physicsBody = bodyPhysics
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }

    func updateRig(velocity: CGVector, lift: CGFloat, phase: CGFloat, squashX: CGFloat, squashY: CGFloat, hazard: Bool, armed: Bool) {
        let speed = hypot(velocity.dx, velocity.dy)
        body.xScale = squashX
        body.yScale = squashY
        body.fillColor = hazard ? DesignTokens.hazardUI : DesignTokens.heroUI
        body.strokeColor = armed ? DesignTokens.hazardUI : DesignTokens.accentUI
        body.lineWidth = armed ? 3.5 : 2.5
        costArc.isHidden = !armed
        costArc.xScale = squashX
        costArc.yScale = max(0.45, squashY * 0.72)
        limb.zRotation = speed < 8 ? 0 : sin(phase) * 0.6
        let aimX: CGFloat
        let aimY: CGFloat
        if speed > 8 {
            aimX = velocity.dx / speed * 2.2
            aimY = velocity.dy / speed * 2.2
        } else {
            aimX = 0
            aimY = 0
        }
        leftEye.position = CGPoint(x: -4.5 + aimX, y: 1.5 + aimY)
        rightEye.position = CGPoint(x: 4.5 + aimX, y: 1.5 + aimY)
        let rise = min(1, max(0, lift / 90))
        shadow.position = CGPoint(x: 0, y: -8 - lift)
        shadow.xScale = max(0.4, 1 - rise * 0.55)
        shadow.yScale = max(0.4, 1 - rise * 0.35)
        shadow.alpha = max(0.22, 1 - rise * 0.65)
    }
}
