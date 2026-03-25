#if os(watchOS)
import SwiftUI

// MARK: - WatchCardView

public struct WatchCardView<Content: View>: View {
    let content: Content

    @Environment(\.donkeyTheme) var theme

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(theme.spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: theme.shape.radiusMedium)
                    .fill(theme.colors.surface)
            )
    }
}

// MARK: - Preview

struct WatchCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 8) {
                WatchCardView {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Steps")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("8,432")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }

                WatchCardView {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                        Text("72 BPM")
                            .fontWeight(.semibold)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}
#endif
