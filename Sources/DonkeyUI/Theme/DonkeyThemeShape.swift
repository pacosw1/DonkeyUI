import SwiftUI

public struct DonkeyThemeShape: Sendable {

    public var radiusSmall: CGFloat
    public var radiusMedium: CGFloat
    public var radiusLarge: CGFloat
    public var radiusXL: CGFloat
    public var radiusFull: CGFloat

    public init(
        radiusSmall: CGFloat = 5,
        radiusMedium: CGFloat = 12,
        radiusLarge: CGFloat = 18,
        radiusXL: CGFloat = 22,
        radiusFull: CGFloat = 999
    ) {
        self.radiusSmall = radiusSmall
        self.radiusMedium = radiusMedium
        self.radiusLarge = radiusLarge
        self.radiusXL = radiusXL
        self.radiusFull = radiusFull
    }
}
