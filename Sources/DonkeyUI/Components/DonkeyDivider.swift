import SwiftUI

// MARK: - DonkeyDivider

public struct DonkeyDivider: View {
    let label: String?
    let color: Color?
    let thickness: CGFloat

    @Environment(\.donkeyTheme) var theme

    public init(
        label: String? = nil,
        color: Color? = nil,
        thickness: CGFloat = 1
    ) {
        self.label = label
        self.color = color
        self.thickness = thickness
    }

    private var resolvedColor: Color {
        color ?? theme.colors.border
    }

    public var body: some View {
        if let label = label {
            labeledDivider(label)
        } else {
            line
        }
    }

    private var line: some View {
        Rectangle()
            .fill(resolvedColor)
            .frame(height: thickness)
    }

    private func labeledDivider(_ text: String) -> some View {
        HStack(spacing: theme.spacing.md) {
            line
            Text(text)
                .font(theme.typography.caption)
                .fontWeight(theme.typography.defaultWeight)
                .foregroundStyle(theme.colors.secondary)
                .lineLimit(1)
                .layoutPriority(1)
            line
        }
    }
}

// MARK: - Preview

struct DonkeyDivider_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            DonkeyDivider()

            DonkeyDivider(label: "or")

            DonkeyDivider(label: "Section Title")

            DonkeyDivider(label: "continue with", color: .blue)

            DonkeyDivider(thickness: 2)

            DonkeyDivider(label: "OR", color: .orange, thickness: 2)
        }
        .padding()
    }
}
