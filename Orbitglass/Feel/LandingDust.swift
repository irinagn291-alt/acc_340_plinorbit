import SpriteKit
import UIKit

/// Pooled landing dust. Bursts are finite; nothing is allocated inside the frame loop.
@MainActor
final class LandingDust {
    private var nodes: [SKEmitterNode] = []
    private var cursor = 0

    func attach(to scene: SKScene) {
        guard nodes.isEmpty else { return }
        for _ in 0..<4 {
            let node = LandingDust.makeEmitter()
            node.targetNode = scene
            scene.addChild(node)
            nodes.append(node)
        }
    }

    func burst(at point: CGPoint, tint: UIColor, reduced: Bool) {
        guard !reduced, !nodes.isEmpty else { return }
        let node = nodes[cursor % nodes.count]
        cursor += 1
        node.isHidden = false
        node.position = point
        node.particleColor = tint
        node.particleBirthRate = 0
        node.resetSimulation()
        node.numParticlesToEmit = 12
        node.particleBirthRate = 280
        node.advanceSimulationTime(0.06)
        node.particleBirthRate = 0
    }

    private static func makeEmitter() -> SKEmitterNode {
        let node = SKEmitterNode()
        node.name = "landingDust"
        node.particleTexture = speck
        node.particleBirthRate = 0
        node.numParticlesToEmit = 1
        node.particleLifetime = 0.32
        node.particleLifetimeRange = 0.08
        node.particleSpeed = 42
        node.particleSpeedRange = 18
        node.emissionAngle = .pi / 2
        node.emissionAngleRange = 1.35
        node.particleAlpha = 0.75
        node.particleAlphaSpeed = -2.1
        node.particleScale = 0.32
        node.particleScaleSpeed = 0.55
        node.particleColorBlendFactor = 1
        node.particleSize = CGSize(width: 9, height: 9)
        node.particlePositionRange = CGVector(dx: 10, dy: 3)
        node.zPosition = 33
        node.position = CGPoint(x: -900, y: -900)
        return node
    }

    private static let speck: SKTexture = {
        let size = CGSize(width: 12, height: 12)
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 1
        let image = UIGraphicsImageRenderer(size: size, format: format).image { renderer in
            let context = renderer.cgContext
            context.clear(CGRect(origin: .zero, size: size))
            context.setFillColor(UIColor.white.cgColor)
            context.fillEllipse(in: CGRect(x: 1, y: 1, width: 10, height: 10))
        }
        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        return texture
    }()
}
