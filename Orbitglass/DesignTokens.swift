import SwiftUI
import UIKit

/// SPEC section 7. The only place these hex values live — reach colours
/// and the font family through here. Keep this file and its values.
enum DesignTokens {
    /// #1A1420
    static let bg = Color(red: 0.101961, green: 0.078431, blue: 0.125490)
    static let bgHex = "#1A1420"
    /// #261C2E
    static let surface = Color(red: 0.149020, green: 0.109804, blue: 0.180392)
    static let surfaceHex = "#261C2E"
    /// #F6F1E8
    static let ink = Color(red: 0.964706, green: 0.945098, blue: 0.909804)
    static let inkHex = "#F6F1E8"
    /// #E07A5F
    static let accent = Color(red: 0.878431, green: 0.478431, blue: 0.372549)
    static let accentHex = "#E07A5F"
    /// #A898A8
    static let muted = Color(red: 0.658824, green: 0.596078, blue: 0.658824)
    static let mutedHex = "#A898A8"
    /// #140E18
    static let sky = Color(red: 0.078431, green: 0.054902, blue: 0.094118)
    static let skyHex = "#140E18"
    /// #32243C
    static let far = Color(red: 0.196078, green: 0.141176, blue: 0.235294)
    static let farHex = "#32243C"
    /// #4C3858
    static let mid = Color(red: 0.298039, green: 0.219608, blue: 0.345098)
    static let midHex = "#4C3858"
    /// #E6D9C8
    static let ground = Color(red: 0.901961, green: 0.850980, blue: 0.784314)
    static let groundHex = "#E6D9C8"
    /// #FFF9F3
    static let hero = Color(red: 1.000000, green: 0.976471, blue: 0.952941)
    static let heroHex = "#FFF9F3"
    /// #D4524A
    static let hazard = Color(red: 0.831373, green: 0.321569, blue: 0.290196)
    static let hazardHex = "#D4524A"
    /// #F2C14E
    static let collectible = Color(red: 0.949020, green: 0.756863, blue: 0.305882)
    static let collectibleHex = "#F2C14E"
    /// #E7DDE8
    static let weather = Color(red: 0.905882, green: 0.866667, blue: 0.909804)
    static let weatherHex = "#E7DDE8"
    /// #0C0810
    static let shadow = Color(red: 0.047059, green: 0.031373, blue: 0.062745)
    static let shadowHex = "#0C0810"
    static let fontFamily = "Avenir Next"

    static let bgUI = UIColor(red: 0.101961, green: 0.078431, blue: 0.125490, alpha: 1)
    static let surfaceUI = UIColor(red: 0.149020, green: 0.109804, blue: 0.180392, alpha: 1)
    static let inkUI = UIColor(red: 0.964706, green: 0.945098, blue: 0.909804, alpha: 1)
    static let accentUI = UIColor(red: 0.878431, green: 0.478431, blue: 0.372549, alpha: 1)
    static let mutedUI = UIColor(red: 0.658824, green: 0.596078, blue: 0.658824, alpha: 1)
    static let skyUI = UIColor(red: 0.078431, green: 0.054902, blue: 0.094118, alpha: 1)
    static let farUI = UIColor(red: 0.196078, green: 0.141176, blue: 0.235294, alpha: 1)
    static let midUI = UIColor(red: 0.298039, green: 0.219608, blue: 0.345098, alpha: 1)
    static let groundUI = UIColor(red: 0.901961, green: 0.850980, blue: 0.784314, alpha: 1)
    static let heroUI = UIColor(red: 1.000000, green: 0.976471, blue: 0.952941, alpha: 1)
    static let hazardUI = UIColor(red: 0.831373, green: 0.321569, blue: 0.290196, alpha: 1)
    static let collectibleUI = UIColor(red: 0.949020, green: 0.756863, blue: 0.305882, alpha: 1)
    static let weatherUI = UIColor(red: 0.905882, green: 0.866667, blue: 0.909804, alpha: 1)
    static let shadowUI = UIColor(red: 0.047059, green: 0.031373, blue: 0.062745, alpha: 1)
}

enum DomeType {
    static func regular(_ size: CGFloat) -> UIFont {
        UIFont(name: "AvenirNext-Regular", size: size) ?? .systemFont(ofSize: size, weight: .regular)
    }

    static func demi(_ size: CGFloat) -> UIFont {
        UIFont(name: "AvenirNext-DemiBold", size: size) ?? .systemFont(ofSize: size, weight: .semibold)
    }

    static func bold(_ size: CGFloat) -> UIFont {
        UIFont(name: "AvenirNext-Bold", size: size) ?? .boldSystemFont(ofSize: size)
    }

    static func digits(_ size: CGFloat) -> UIFont {
        let base = demi(size)
        let descriptor = base.fontDescriptor.addingAttributes([
            UIFontDescriptor.AttributeName.featureSettings: [
                [
                    UIFontDescriptor.FeatureKey.type: kNumberSpacingType,
                    UIFontDescriptor.FeatureKey.selector: kMonospacedNumbersSelector,
                ],
            ],
        ])
        return UIFont(descriptor: descriptor, size: size)
    }
}
