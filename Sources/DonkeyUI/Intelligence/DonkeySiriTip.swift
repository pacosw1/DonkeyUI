#if canImport(AppIntents) && os(iOS)
import SwiftUI
import AppIntents

/// A themed Siri tip view that suggests a voice shortcut to the user.
public struct DonkeySiriTip<Intent: AppIntent>: View {
    @Environment(\.donkeyTheme) var theme

    let intent: Intent
    @Binding var isVisible: Bool

    public init(intent: Intent, isVisible: Binding<Bool>) {
        self.intent = intent
        self._isVisible = isVisible
    }

    public var body: some View {
        if isVisible {
            SiriTipView(intent: intent, isVisible: $isVisible)
                .padding(theme.spacing.md)
                .background(theme.colors.surface)
                .clipShape(RoundedRectangle(cornerRadius: theme.shape.radiusMedium))
        }
    }
}

// MARK: - View Extension

public extension View {
    /// Shows a themed Siri tip overlay.
    func donkeySiriTip<I: AppIntent>(_ intent: I, isVisible: Binding<Bool>) -> some View {
        overlay(alignment: .bottom) {
            DonkeySiriTip(intent: intent, isVisible: isVisible)
                .padding(8)
        }
    }
}
#endif
