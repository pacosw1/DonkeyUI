import SwiftUI

// MARK: - Server-Driven Paywall Config

/// Configuration for the paywall promo section. Designed to be fetched from a server
/// and cached locally, with a hardcoded default fallback.
public struct PaywallConfig {
    public let headline: String
    public let headlineAccent: String
    public let subtitle: String
    public let memberCount: String
    public let rating: String
    public let features: [PaywallEmojiFeature]
    public let reviews: [PaywallReview]
    public let footerText: String

    public init(
        headline: String,
        headlineAccent: String,
        subtitle: String = "",
        memberCount: String = "",
        rating: String = "4.8",
        features: [PaywallEmojiFeature] = [],
        reviews: [PaywallReview] = [],
        footerText: String = ""
    ) {
        self.headline = headline
        self.headlineAccent = headlineAccent
        self.subtitle = subtitle
        self.memberCount = memberCount
        self.rating = rating
        self.features = features
        self.reviews = reviews
        self.footerText = footerText
    }
}

/// A feature with emoji icon and colored background circle.
public struct PaywallEmojiFeature: Identifiable {
    public let id: String
    public let emoji: String
    public let color: Color
    public let text: String
    public let boldWord: String

    public init(
        id: String = UUID().uuidString,
        emoji: String,
        color: Color,
        text: String,
        boldWord: String = ""
    ) {
        self.id = id
        self.emoji = emoji
        self.color = color
        self.text = text
        self.boldWord = boldWord
    }
}

/// An app review for the reviews carousel.
public struct PaywallReview: Identifiable {
    public let id: String
    public let title: String
    public let username: String
    public let timeLabel: String
    public let description: String
    public let rating: Int

    public init(
        id: String = UUID().uuidString,
        title: String,
        username: String,
        timeLabel: String = "",
        description: String,
        rating: Int = 5
    ) {
        self.id = id
        self.title = title
        self.username = username
        self.timeLabel = timeLabel
        self.description = description
        self.rating = rating
    }
}

// MARK: - PaywallScreen

public struct PaywallScreen: View {
    let config: PaywallConfig
    let plans: [PaywallPlanOption]
    @Binding var selectedPlanId: String?
    let isLoading: Bool
    let isPremium: Bool
    let ctaLabel: String
    let privacyURL: URL?
    let termsURL: URL?
    let onPurchase: (PaywallPlanOption) -> Void
    let onRestore: () -> Void
    let onDismiss: (() -> Void)?

    @Environment(\.donkeyTheme) var theme

    public init(
        config: PaywallConfig,
        plans: [PaywallPlanOption],
        selectedPlanId: Binding<String?>,
        isLoading: Bool = false,
        isPremium: Bool = false,
        ctaLabel: String = "Continue",
        privacyURL: URL? = nil,
        termsURL: URL? = nil,
        onPurchase: @escaping (PaywallPlanOption) -> Void,
        onRestore: @escaping () -> Void,
        onDismiss: (() -> Void)? = nil
    ) {
        self.config = config
        self.plans = plans
        self._selectedPlanId = selectedPlanId
        self.isLoading = isLoading
        self.isPremium = isPremium
        self.ctaLabel = ctaLabel
        self.privacyURL = privacyURL
        self.termsURL = termsURL
        self.onPurchase = onPurchase
        self.onRestore = onRestore
        self.onDismiss = onDismiss
    }

    private var selectedPlan: PaywallPlanOption? {
        plans.first(where: { $0.id == selectedPlanId })
    }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(spacing: 0) {
                // Promo section (scrollable)
                promoSection

                // Purchase section (fixed at bottom)
                purchaseSection
                    .background(theme.colors.surface)
            }

            // Close button
            if let onDismiss {
                CloseButton(action: onDismiss)
                    .padding(theme.spacing.lg)
            }
        }
        .background(theme.colors.background.ignoresSafeArea())
        .overlay {
            if isLoading {
                ZStack {
                    Color.black.opacity(0.7)
                    ProgressView()
                        .tint(.white)
                }
                .ignoresSafeArea()
                .transition(.opacity)
            }
        }
    }

    // MARK: - Promo Section (scrollable top half)

    private var promoSection: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Hero headline
                heroSection
                    .padding()

                DonkeyDivider()

                VStack(alignment: .leading, spacing: theme.spacing.md) {
                    // Social proof
                    if !config.memberCount.isEmpty {
                        socialProofSection
                            .padding([.top, .horizontal])
                    }

                    // Reviews carousel
                    if !config.reviews.isEmpty {
                        reviewsCarousel
                            .padding(.vertical, theme.spacing.md)
                    }

                    if !config.features.isEmpty {
                        DonkeyDivider()
                            .padding(.top, theme.spacing.sm)

                        // Emoji features grid
                        emojiFeatureGrid
                            .padding(.horizontal, theme.spacing.xxl)
                            .padding(.top, theme.spacing.md)
                    }

                    if !config.footerText.isEmpty {
                        DonkeyDivider()
                            .padding(.bottom, theme.spacing.xs)

                        HStack {
                            Text(config.footerText)
                                .font(theme.typography.caption)
                                .foregroundStyle(theme.colors.secondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xxs) {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(config.headline) ")
                    .font(theme.typography.largeTitle)
                    .fontWeight(.regular)
                +
                Text(config.headlineAccent)
                    .font(theme.typography.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(theme.colors.accent)
            }

            if !config.subtitle.isEmpty {
                Text(config.subtitle)
                    .foregroundStyle(theme.colors.secondary)
            }
        }
    }

    // MARK: - Social Proof

    private var socialProofSection: some View {
        VStack(alignment: .leading, spacing: theme.spacing.xs) {
            Text(config.memberCount)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.secondary)
                .fontWeight(.heavy)

            HStack(spacing: 0) {
                Text(config.rating)
                    .font(theme.typography.title2)
                    .fontWeight(.heavy)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    .bgOverlay(
                        bgColor: theme.colors.surface,
                        radius: theme.shape.radiusLarge,
                        borderColor: theme.colors.borderSubtle,
                        borderWidth: 1
                    )
                    .padding(.trailing, theme.spacing.xs)

                ForEach(0..<5) { i in
                    Image(systemName: i < 4 ? "star.fill" : "star.leadinghalf.filled")
                }
                .foregroundStyle(.orange)
            }
        }
    }

    // MARK: - Reviews Carousel

    private var reviewsCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 12) {
                ForEach(config.reviews) { review in
                    reviewCard(review)
                }
                .containerRelativeFrame(.horizontal)
            }
            .scrollTargetLayout()
        }
        .contentMargins(.horizontal, 20.0, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
    }

    private func reviewCard(_ review: PaywallReview) -> some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(alignment: .center) {
                    Text(review.title)
                        .font(theme.typography.subheadline)
                        .fontWeight(.bold)
                    Spacer()
                    Text(review.timeLabel)
                        .foregroundStyle(theme.colors.secondary)
                        .font(theme.typography.caption)
                }
                HStack(alignment: .top) {
                    HStack(spacing: 1) {
                        ForEach(1..<6) { i in
                            Image(systemName: i <= review.rating ? "star.fill" : "star")
                                .foregroundStyle(.orange)
                                .font(.system(size: 11))
                        }
                    }
                    Spacer()
                    Text(review.username)
                        .foregroundStyle(theme.colors.secondary)
                        .font(theme.typography.caption)
                }
            }
            .padding(.bottom, 10)

            Text(review.description)
                .font(.system(size: 15))
            Spacer()
        }
        .frame(height: 150)
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .bgOverlay(
            bgColor: theme.colors.surface,
            radius: theme.shape.radiusSmall,
            borderColor: theme.colors.borderSubtle,
            borderWidth: 1
        )
    }

    // MARK: - Emoji Feature Grid

    private var emojiFeatureGrid: some View {
        Grid(alignment: .leading, horizontalSpacing: 22, verticalSpacing: 15) {
            ForEach(config.features) { feature in
                GridRow {
                    // Emoji circle
                    Text(feature.emoji)
                        .font(.system(size: 14))
                        .background {
                            Circle()
                                .fill(feature.color.opacity(0.3))
                                .frame(width: 38, height: 38)
                        }

                    // Feature text with optional bold word
                    featureText(feature)
                        .padding(10)
                        .bgOverlay(
                            bgColor: theme.colors.surface,
                            radius: theme.shape.radiusMedium,
                            borderColor: theme.colors.borderSubtle,
                            borderWidth: 1
                        )
                }
            }
        }
        .font(.system(size: 13))
    }

    @ViewBuilder
    private func featureText(_ feature: PaywallEmojiFeature) -> some View {
        if feature.boldWord.isEmpty {
            Text(feature.text)
                .foregroundStyle(theme.colors.onSurface)
        } else {
            Text("\(Text(feature.boldWord).foregroundStyle(theme.colors.accent).fontWeight(.bold)) \(feature.text)")
                .foregroundStyle(theme.colors.onSurface)
        }
    }

    // MARK: - Purchase Section (fixed bottom)

    private var purchaseSection: some View {
        VStack(spacing: 0) {
            Divider()
                .overlay(theme.colors.border)

            VStack(spacing: theme.spacing.md) {
                // Plan cards
                planSection
                    .padding(.horizontal)

                // CTA button
                if isPremium {
                    Text("You are already a premium user")
                        .fontWeight(.bold)
                        .foregroundStyle(theme.colors.secondary)
                        .font(theme.typography.caption)
                }

                ThemedButton(
                    ctaLabel,
                    role: .primary,
                    fullWidth: true,
                    isLoading: isLoading,
                    disabled: selectedPlan == nil || isLoading || isPremium,
                    action: {
                        guard let plan = selectedPlan else { return }
                        onPurchase(plan)
                    }
                )
                .padding(.horizontal)

                // Footer links
                footerSection
            }
            .padding(.vertical, theme.spacing.md)
        }
    }

    // MARK: - Plan Cards

    private var planSection: some View {
        VStack(spacing: theme.spacing.sm) {
            ForEach(plans) { plan in
                planCard(plan)
            }
        }
        .padding(.top, theme.spacing.sm)
    }

    private func planCard(_ plan: PaywallPlanOption) -> some View {
        let isSelected = selectedPlanId == plan.id
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPlanId = plan.id
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text(plan.title)
                        .font(theme.typography.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(theme.colors.onSurface)
                    if !plan.subtitle.isEmpty {
                        Text(plan.subtitle)
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.secondary)
                    }
                }
                Spacer()
                Text(plan.priceDisplay)
                    .fontWeight(.semibold)
                    .foregroundColor(isSelected ? theme.colors.onSurface : theme.colors.secondary.opacity(0.9))
                    .font(theme.typography.body)
                    .padding(.vertical, 6)
                    .frame(minWidth: 90)
                    .bgOverlay(bgColor: theme.colors.secondary.opacity(0.15), radius: 15)
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .bgOverlay(
                bgColor: isSelected ? theme.colors.primary.opacity(0.06) : theme.colors.surface,
                radius: theme.shape.radiusMedium,
                borderColor: isSelected ? theme.colors.primary : theme.colors.borderSubtle,
                borderWidth: isSelected ? 2 : 1
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Footer

    private var footerSection: some View {
        HStack(spacing: theme.spacing.lg) {
            Spacer()
            if let privacyURL {
                Link("Privacy", destination: privacyURL)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.secondary)
            }

            Button("Restore Purchases", action: onRestore)
                .font(theme.typography.caption)

            if let termsURL {
                Link("Terms", destination: termsURL)
                    .font(theme.typography.caption)
                    .foregroundColor(theme.colors.secondary)
            }
            Spacer()
        }
        .padding(.top, theme.spacing.xs)
    }
}

// MARK: - Preview

struct PaywallScreen_Previews: PreviewProvider {
    static var previews: some View {
        PaywallScreenPreviewWrapper()
    }

    struct PaywallScreenPreviewWrapper: View {
        @State private var selected: String? = "annual"

        var body: some View {
            PaywallScreen(
                config: PaywallConfig(
                    headline: "GET YOUR SH*T",
                    headlineAccent: "TOGETHER",
                    subtitle: "Don't just track habits, turn your life around",
                    memberCount: "50,000+ Members changing their life",
                    rating: "4.6",
                    features: [
                        .init(emoji: "🏋️", color: Color(hex: "#D2D4C8") ?? .gray, text: "habits", boldWord: "Unlimited"),
                        .init(emoji: "📲", color: Color(hex: "#94B0DA") ?? .blue, text: "Homescreen", boldWord: "Widgets"),
                        .init(emoji: "📅", color: Color(hex: "#DD9787") ?? .red, text: "Edit Habit History"),
                        .init(emoji: "❤️", color: Color(hex: "#2D5D7B") ?? .blue, text: "Support an Independent Developer"),
                        .init(emoji: "☁️", color: Color(hex: "#66717E") ?? .gray, text: "Cloud Sync"),
                        .init(emoji: "🔔", color: Color(hex: "#274690") ?? .blue, text: "Reminders", boldWord: "Multiple"),
                    ],
                    reviews: [
                        .init(title: "I'm super picky and this is perfect", username: "Tayl0rDev", timeLabel: "3d ago", description: "As I said above, I'm super picky with what I want out of a habit tracking app and this one is perfect."),
                        .init(title: "Clean and minimal", username: "U_B_W", timeLabel: "1w ago", description: "Does what it does and nothing more. Perfect. Dear dev, focus on stability."),
                        .init(title: "Really great app", username: "LuegmayerM", timeLabel: "3d ago", description: "The app is appealing in design yet simple. Everything works very quickly and well."),
                    ],
                    footerText: "Made with ❤️ by Paco Sainz"
                ),
                plans: [
                    PaywallPlanOption(
                        id: "monthly",
                        title: "Monthly",
                        subtitle: "Recurring Billing",
                        priceDisplay: "$2.99",
                        period: "/month"
                    ),
                    PaywallPlanOption(
                        id: "annual",
                        title: "Annual",
                        subtitle: "Save 50%",
                        priceDisplay: "$14.99",
                        period: "/year",
                        isBestValue: true
                    ),
                ],
                selectedPlanId: $selected,
                ctaLabel: "Continue",
                privacyURL: URL(string: "https://example.com/privacy"),
                termsURL: URL(string: "https://example.com/terms"),
                onPurchase: { _ in },
                onRestore: {},
                onDismiss: {}
            )
            .preferredColorScheme(.dark)
        }
    }
}
