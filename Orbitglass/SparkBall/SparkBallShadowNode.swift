import SpriteKit
import UIKit

/// Ground shadow. Kept off the body so a bounce can lift the glass without lifting the shade.
final class SparkBallShadowNode: SKShapeNode {
    override init() {
        super.init()
        let path = CGPath(ellipseIn: CGRect(x: -16, y: -5, width: 32, height: 10), transform: nil)
        self.path = path
        fillColor = DesignTokens.shadowUI.withAlphaComponent(0.72)
        strokeColor = .clear
        name = "shadow"
        zPosition = 19
    }

    required init?(coder aDecoder: NSCoder) {
        nil
    }
}
