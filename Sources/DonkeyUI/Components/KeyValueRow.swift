import SwiftUI

// MARK: - KeyValueRow

public struct KeyValueRow: View {
    let label: String
    let value: String
    let systemIcon: String?
    let copiable: Bool

    @Environment(\.donkeyTheme) var theme
    @State private var showCopied = false

    public init(
        label: String,
        value: String,
        systemIcon: String? = nil,
        copiable: Bool = false
    ) {
        self.label = label
        self.value = value
        self.systemIcon = systemIcon
        self.copiable = copiable
    }

    public var body: some View {
        HStack(spacing: theme.spacing.md) {
            if let systemIcon = systemIcon {
                Image(systemName: systemIcon)
                    .font(theme.typography.callout)
                    .foregroundColor(theme.colors.primary)
                    .frame(width: 24, alignment: .center)
            }

            Text(label)
                .font(theme.typography.body)
                .foregroundColor(theme.colors.secondary)
                .lineLimit(1)

            Spacer(minLength: theme.spacing.sm)

            Text(value)
                .font(theme.typography.body)
                .fontWeight(theme.typography.emphasisWeight)
                .foregroundColor(theme.colors.onSurface)
                .multilineTextAlignment(.trailing)
                .lineLimit(2)

            if copiable {
                Button {
                    copyToClipboard(value)
                    DonkeyHaptics.success()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showCopied = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation(.easeOut(duration: 0.2)) {
                            showCopied = false
                        }
                    }
                } label: {
                    Image(systemName: showCopied ? "checkmark" : "doc.on.doc")
                        .font(theme.typography.caption)
                        .foregroundColor(showCopied ? theme.colors.success : theme.colors.secondary)
                        .frame(width: 24, height: 24)
                        .contentTransition(.symbolEffect(.replace))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, theme.spacing.sm)
    }

    private func copyToClipboard(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif
    }
}

// MARK: - Preview

struct KeyValueRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            KeyValueRow(
                label: "Name",
                value: "John Doe",
                systemIcon: "person"
            )

            Divider()

            KeyValueRow(
                label: "Email",
                value: "john@example.com",
                systemIcon: "envelope",
                copiable: true
            )

            Divider()

            KeyValueRow(
                label: "Version",
                value: "2.4.1"
            )

            Divider()

            KeyValueRow(
                label: "API Key",
                value: "sk-abc123xyz789",
                copiable: true
            )

            Divider()

            KeyValueRow(
                label: "Status",
                value: "Active",
                systemIcon: "checkmark.circle.fill"
            )
        }
        .padding(.horizontal)
    }
}
