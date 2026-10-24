import SpriteKit
import UIKit

/// Loads `ogb_` imagesets and draws a procedural stand-in when the texture is missing.
@MainActor
enum WorldArt {
    static let backdropFar = "BackdropFar"
    static let backdropMid = "BackdropMid"
    static let collectible = "Collectible"
    static let propNear = "PropNear"
    static let propFar = "PropFar"

    private static var cache: [String: SKTexture] = [:]

    static func sprite(stem: String, size: CGSize) -> SKSpriteNode {
        let node = SKSpriteNode(texture: texture(stem: stem, size: size), size: size)
        node.name = stem
        return node
    }

    static func texture(stem: String, size: CGSize) -> SKTexture {
        let key = "\(stem)-\(Int(size.width))x\(Int(size.height))"
        if let cached = cache[key] {
            return cached
        }
        let image = UIImage(named: "ogb_\(stem)") ?? UIImage(named: stem)
        let texture: SKTexture
        if let image, image.size.width > 1, image.size.height > 1 {
            texture = SKTexture(image: image)
        } else {
            texture = SKTexture(image: procedural(stem: stem, size: size))
        }
        texture.filteringMode = .linear
        cache[key] = texture
        return texture
    }

    private static func procedural(stem: String, size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            let canvas = CGRect(origin: .zero, size: size)
            let cg = context.cgContext
            switch stem {
            case backdropFar:
                DesignTokens.skyUI.setFill()
                cg.fill(canvas)
                DesignTokens.farUI.setFill()
                let dome = CGRect(x: -size.width * 0.1, y: size.height * 0.18, width: size.width * 1.2, height: size.height * 0.72)
                cg.fillEllipse(in: dome)
                DesignTokens.shadowUI.withAlphaComponent(0.45).setFill()
                cg.fillEllipse(in: CGRect(x: size.width * 0.08, y: size.height * 0.28, width: size.width * 0.22, height: size.height * 0.16))
            case backdropMid:
                DesignTokens.midUI.setFill()
                cg.fill(canvas)
                DesignTokens.farUI.setFill()
                cg.fillEllipse(in: CGRect(x: size.width * 0.06, y: size.height * 0.22, width: size.width * 0.88, height: size.height * 0.62))
                DesignTokens.groundUI.withAlphaComponent(0.18).setFill()
                cg.fillEllipse(in: CGRect(x: size.width * 0.2, y: size.height * 0.38, width: size.width * 0.55, height: size.height * 0.28))
            case collectible:
                UIColor.clear.setFill()
                cg.fill(canvas)
                DesignTokens.collectibleUI.setFill()
                cg.addPath(starPath(in: canvas.insetBy(dx: size.width * 0.22, dy: size.height * 0.22)))
                cg.fillPath()
            case propNear:
                UIColor.clear.setFill()
                cg.fill(canvas)
                DesignTokens.weatherUI.setFill()
                let blob = canvas.insetBy(dx: size.width * 0.24, dy: size.height * 0.28)
                cg.fillEllipse(in: blob)
                DesignTokens.heroUI.withAlphaComponent(0.8).setFill()
                cg.fillEllipse(in: blob.insetBy(dx: blob.width * 0.28, dy: blob.height * 0.32))
            case propFar:
                UIColor.clear.setFill()
                cg.fill(canvas)
                DesignTokens.groundUI.setFill()
                let base = CGRect(x: size.width * 0.34, y: size.height * 0.18, width: size.width * 0.32, height: size.height * 0.62)
                cg.fill(base)
                cg.fillEllipse(in: CGRect(x: size.width * 0.3, y: size.height * 0.62, width: size.width * 0.4, height: size.height * 0.16))
            default:
                DesignTokens.midUI.setFill()
                cg.fill(canvas)
            }
        }
    }

    private static func starPath(in rect: CGRect) -> CGPath {
        let path = CGMutablePath()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.42
        for index in 0..<10 {
            let angle = CGFloat(index) * .pi / 5 - .pi / 2
            let radius = index.isMultiple(of: 2) ? outer : inner
            let point = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}
