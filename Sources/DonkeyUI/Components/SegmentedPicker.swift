import SwiftUI

// MARK: - SegmentedPicker

public struct SegmentedPicker<T: Hashable & CaseIterable & CustomStringConvertible>: View
where T.AllCases: RandomAccessCollection {

    @Binding var selection: T
    @Namespace private var namespace

    @Environment(\.donkeyTheme) var theme

    public init(selection: Binding<T>) {
        self._selection = selection
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(T.allCases), id: \.self) { item in
                segmentButton(for: item)
            }
        }
        .padding(theme.spacing.xs)
        .bgOverlay(
            bgColor: theme.colors.surface,
            radius: theme.shape.radiusMedium
        )
    }

    private func segmentButton(for item: T) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                selection = item
            }
        } label: {
            Text(item.description)
                .font(theme.typography.subheadline)
                .fontWeight(selection == item ? theme.typography.emphasisWeight : theme.typography.defaultWeight)
                .foregroundStyle(selection == item ? theme.colors.onSurface : theme.colors.secondary)
                .lineLimit(1)
                .frame(maxWidth: .infinity)
                .padding(.vertical, theme.spacing.sm)
                .padding(.horizontal, theme.spacing.md)
                .background {
                    if selection == item {
                        RoundedRectangle(cornerRadius: theme.shape.radiusSmall + 2, style: .continuous)
                            .fill(theme.colors.background)
                            .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                            .matchedGeometryEffect(id: "selectedSegment", in: namespace)
                    }
                }
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

private enum PreviewTab: String, CaseIterable, CustomStringConvertible {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"

    var description: String { rawValue }
}

private enum PreviewFilter: String, CaseIterable, CustomStringConvertible {
    case all = "All"
    case active = "Active"
    case archived = "Archived"

    var description: String { rawValue }
}

struct SegmentedPicker_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            SegmentedPicker<PreviewTab>(selection: .constant(.daily))
            SegmentedPicker<PreviewTab>(selection: .constant(.weekly))
            SegmentedPicker<PreviewFilter>(selection: .constant(.all))
            SegmentedPicker<PreviewFilter>(selection: .constant(.active))
        }
        .padding()
    }
}
