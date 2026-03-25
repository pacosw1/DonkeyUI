#if os(watchOS)
import SwiftUI

public extension DonkeyTheme {
    /// Returns a copy of this theme with adjustments suited for watchOS:
    /// tighter spacing, bolder weights, and smaller corner radii.
    func watchAdjusted() -> DonkeyTheme {
        DonkeyTheme(
            colors: colors,
            typography: DonkeyThemeTypography(
                largeTitle: typography.largeTitle,
                title: typography.title,
                title2: typography.title2,
                title3: typography.title3,
                headline: typography.headline,
                body: typography.body,
                callout: typography.callout,
                subheadline: typography.subheadline,
                footnote: typography.footnote,
                caption: typography.caption,
                caption2: typography.caption2,
                defaultWeight: .medium,
                emphasisWeight: .bold,
                heavyWeight: typography.heavyWeight
            ),
            shape: DonkeyThemeShape(
                radiusSmall: shape.radiusSmall,
                radiusMedium: 10,
                radiusLarge: 14,
                radiusXL: 18,
                radiusFull: shape.radiusFull
            ),
            spacing: DonkeyThemeSpacing(
                xxs: spacing.xxs,
                xs: spacing.xs,
                sm: spacing.sm,
                md: spacing.md,
                lg: 12,
                xl: 16,
                xxl: 24,
                xxxl: 32
            )
        )
    }
}
#endif
