import SwiftUI

// MARK: - ReviewCard

public struct ReviewCard: View {
    let authorName: String
    let rating: Int
    let title: String?
    let bodyText: String
    let date: Date?

    @Environment(\.donkeyTheme) var theme

    public init(
        authorName: String,
        rating: Int,
        title: String? = nil,
        bodyText: String,
        date: Date? = nil
    ) {
        self.authorName = authorName
        self.rating = min(max(rating, 0), 5)
        self.title = title
        self.bodyText = bodyText
        self.date = date
    }

    public var body: some View {
        ThemedCard(variant: .elevated) {
            VStack(alignment: .leading, spacing: theme.spacing.sm) {
                // Star rating
                HStack(spacing: theme.spacing.xxs) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(theme.typography.caption)
                            .foregroundStyle(star <= rating ? .orange : theme.colors.borderSubtle)
                    }
                }

                // Title
                if let title = title, !title.isEmpty {
                    Text(title)
                        .font(theme.typography.headline)
                        .fontWeight(theme.typography.emphasisWeight)
                        .foregroundStyle(theme.colors.onSurface)
                }

                // Body
                Text(bodyText)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.onSurface.opacity(0.85))
                    .fixedSize(horizontal: false, vertical: true)

                // Author + date
                HStack {
                    Text(authorName)
                        .font(theme.typography.footnote)
                        .fontWeight(theme.typography.emphasisWeight)
                        .foregroundStyle(theme.colors.secondary)

                    if let date = date {
                        Text("·")
                            .font(theme.typography.footnote)
                            .foregroundStyle(theme.colors.secondary.opacity(0.5))

                        Text(DonkeyDateFormatter.format(date, style: .relative))
                            .font(theme.typography.footnote)
                            .foregroundStyle(theme.colors.secondary)
                    }

                    Spacer()
                }
            }
        }
    }
}

// MARK: - Preview

struct ReviewCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            ReviewCard(
                authorName: "Sarah K.",
                rating: 5,
                title: "Absolutely love it!",
                bodyText: "This app has completely changed how I track my daily habits. The interface is clean and intuitive.",
                date: Calendar.current.date(byAdding: .day, value: -2, to: Date())
            )

            ReviewCard(
                authorName: "Mike R.",
                rating: 4,
                bodyText: "Great app overall. Would love to see widget support in a future update.",
                date: Calendar.current.date(byAdding: .day, value: -14, to: Date())
            )

            ReviewCard(
                authorName: "Anonymous",
                rating: 2,
                title: "Needs work",
                bodyText: "Crashes occasionally when syncing. Please fix."
            )
        }
        .padding()
    }
}
