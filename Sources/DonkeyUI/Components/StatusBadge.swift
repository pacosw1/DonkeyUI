import SwiftUI

// MARK: - BadgeStyle

public enum BadgeStyle {
    case active
    case trial
    case expired
    case cancelled
    case custom(Color)

    public var foregroundColor: Color {
        switch self {
        case .active: return .green
        case .trial: return .blue
        case .expired: return .gray
        case .cancelled: return .red
        case .custom(let color): return color
        }
    }
}

// MARK: - StatusBadge

public struct StatusBadge: View {
    var label: String
    var style: BadgeStyle

    @Environment(\.donkeyTheme) var theme

    public init(label: String, style: BadgeStyle) {
        self.label = label
        self.style = style
    }

    public var body: some View {
        Text(label)
            .font(theme.typography.caption)
            .fontWeight(theme.typography.emphasisWeight)
            .foregroundStyle(style.foregroundColor)
            .padding(.horizontal, theme.spacing.sm + 2)
            .padding(.vertical, theme.spacing.xs)
            .background(
                Capsule(style: .continuous)
                    .fill(style.foregroundColor.opacity(0.12))
            )
            .overlay(
                Capsule(style: .continuous)
                    .strokeBorder(style.foregroundColor.opacity(0.2), lineWidth: 0.5)
            )
    }
}

// MARK: - Preview

struct StatusBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                StatusBadge(label: "Active", style: .active)
                StatusBadge(label: "Trial", style: .trial)
                StatusBadge(label: "Expired", style: .expired)
                StatusBadge(label: "Cancelled", style: .cancelled)
            }

            HStack(spacing: 12) {
                StatusBadge(label: "Pro", style: .custom(.purple))
                StatusBadge(label: "New", style: .custom(.orange))
                StatusBadge(label: "Beta", style: .custom(.indigo))
                StatusBadge(label: "VIP", style: .custom(.pink))
            }

            // In context: list rows
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Premium Plan")
                            .font(.headline)
                        Text("Renews Dec 15, 2026")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    StatusBadge(label: "Active", style: .active)
                }
                .padding()

                Divider()

                HStack {
                    VStack(alignment: .leading) {
                        Text("Basic Plan")
                            .font(.headline)
                        Text("Ended Nov 1, 2026")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    StatusBadge(label: "Expired", style: .expired)
                }
                .padding()
            }
        }
        .padding()
    }
}
