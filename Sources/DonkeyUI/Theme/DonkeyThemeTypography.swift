import SwiftUI

public struct DonkeyThemeTypography: Sendable {

    public var largeTitle: Font
    public var title: Font
    public var title2: Font
    public var title3: Font
    public var headline: Font
    public var body: Font
    public var callout: Font
    public var subheadline: Font
    public var footnote: Font
    public var caption: Font
    public var caption2: Font

    public var defaultWeight: Font.Weight
    public var emphasisWeight: Font.Weight
    public var heavyWeight: Font.Weight

    public init(
        largeTitle: Font = .largeTitle,
        title: Font = .title,
        title2: Font = .title2,
        title3: Font = .title3,
        headline: Font = .headline,
        body: Font = .body,
        callout: Font = .callout,
        subheadline: Font = .subheadline,
        footnote: Font = .footnote,
        caption: Font = .caption,
        caption2: Font = .caption2,
        defaultWeight: Font.Weight = .regular,
        emphasisWeight: Font.Weight = .semibold,
        heavyWeight: Font.Weight = .bold
    ) {
        self.largeTitle = largeTitle
        self.title = title
        self.title2 = title2
        self.title3 = title3
        self.headline = headline
        self.body = body
        self.callout = callout
        self.subheadline = subheadline
        self.footnote = footnote
        self.caption = caption
        self.caption2 = caption2
        self.defaultWeight = defaultWeight
        self.emphasisWeight = emphasisWeight
        self.heavyWeight = heavyWeight
    }
}
