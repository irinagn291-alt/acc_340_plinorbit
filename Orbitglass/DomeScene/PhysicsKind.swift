import Foundation

enum PhysicsKind {
    static let ball: UInt32 = 1 << 0
    static let peg: UInt32 = 1 << 1
    static let star: UInt32 = 1 << 2
    static let pocket: UInt32 = 1 << 3
    static let dead: UInt32 = 1 << 4
}
