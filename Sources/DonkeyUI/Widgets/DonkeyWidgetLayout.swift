#if canImport(WidgetKit)
import SwiftUI
import WidgetKit

// MARK: - Small Widget

/// Pre-built layout for systemSmall widgets with icon, title, and value areas.
public struct DonkeySmallWidget<Content: View>: View {
    private let theme: DonkeyWidgetTheme
    private let content: Content

    public init(
        theme: DonkeyWidgetTheme = .default,
        @ViewBuilder content: () -> Content
    ) {
        self.theme = theme
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.sm) {
            content
        }
        .padding(theme.spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .donkeyContainerBackground(theme.colors.background)
    }
}

// MARK: - Medium Widget

/// Pre-built layout for systemMedium widgets with flexible column/row arrangement.
public struct DonkeyMediumWidget<Content: View>: View {
    private let theme: DonkeyWidgetTheme
    private let content: Content

    public init(
        theme: DonkeyWidgetTheme = .default,
        @ViewBuilder content: () -> Content
    ) {
        self.theme = theme
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: theme.spacing.lg) {
            content
        }
        .padding(theme.spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .donkeyContainerBackground(theme.colors.background)
    }
}

// MARK: - Large Widget

/// Pre-built layout for systemLarge widgets with header and content area.
public struct DonkeyLargeWidget<Header: View, Content: View>: View {
    private let theme: DonkeyWidgetTheme
    private let header: Header
    private let content: Content

    public init(
        theme: DonkeyWidgetTheme = .default,
        @ViewBuilder header: () -> Header,
        @ViewBuilder content: () -> Content
    ) {
        self.theme = theme
        self.header = header()
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            header

            Divider()

            content
                .frame(maxHeight: .infinity, alignment: .top)
        }
        .padding(theme.spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .donkeyContainerBackground(theme.colors.background)
    }
}

// MARK: - Accessory Circular

/// Compact circular layout for accessory widgets.
public struct DonkeyAccessoryCircular<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            content
        }
        .widgetAccentable()
    }
}

// MARK: - Accessory Rectangular

/// Three-line compact layout for rectangular accessory widgets.
public struct DonkeyAccessoryRectangular<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .widgetAccentable()
    }
}

// MARK: - Accessory Inline

/// Inline accessory layout using ViewThatFits with a Label.
public struct DonkeyAccessoryInline<Icon: View>: View {
    private let title: String
    private let icon: Icon

    public init(_ title: String, @ViewBuilder icon: () -> Icon) {
        self.title = title
        self.icon = icon()
    }

    public var body: some View {
        ViewThatFits {
            Label {
                Text(title)
            } icon: {
                icon
            }
            Text(title)
        }
    }
}
#endif
