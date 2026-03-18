import SwiftUI

// MARK: - PaywallScreen

public struct PaywallScreen: View {
    let title: String
    let subtitle: String?
    let features: [PaywallFeatureItem]
    let plans: [PaywallPlanOption]
    @Binding var selectedPlanId: String?
    let isLoading: Bool
    let ctaLabel: String
    let privacyURL: URL?
    let termsURL: URL?
    let onPurchase: (PaywallPlanOption) -> Void
    let onRestore: () -> Void
    let onDismiss: (() -> Void)?

    @Environment(\.donkeyTheme) var theme

    public init(
        title: String,
        subtitle: String? = nil,
        features: [PaywallFeatureItem],
        plans: [PaywallPlanOption],
        selectedPlanId: Binding<String?>,
        isLoading: Bool = false,
        ctaLabel: String = "Continue",
        privacyURL: URL? = nil,
        termsURL: URL? = nil,
        onPurchase: @escaping (PaywallPlanOption) -> Void,
        onRestore: @escaping () -> Void,
        onDismiss: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.features = features
        self.plans = plans
        self._selectedPlanId = selectedPlanId
        self.isLoading = isLoading
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
            ScrollView {
                VStack(spacing: theme.spacing.xl) {
                    // Header
                    headerSection
                        .padding(.top, onDismiss != nil ? theme.spacing.xxxl : theme.spacing.xl)

                    // Features
                    FeatureGrid(features: features, columns: 1)
                        .padding(.horizontal, theme.spacing.lg)

                    // Plans
                    planSection

                    // CTA
                    ctaSection

                    // Footer
                    footerSection
                }
                .padding(.bottom, theme.spacing.xxl)
            }

            // Close button
            if let onDismiss = onDismiss {
                CloseButton(action: onDismiss)
                    .padding(theme.spacing.lg)
            }
        }
        .background(theme.colors.background.ignoresSafeArea())
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: theme.spacing.sm) {
            Text(title)
                .font(theme.typography.largeTitle)
                .fontWeight(theme.typography.heavyWeight)
                .foregroundColor(theme.colors.onBackground)
                .multilineTextAlignment(.center)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.horizontal, theme.spacing.xl)
    }

    // MARK: - Plans

    private var planSection: some View {
        VStack(spacing: theme.spacing.md) {
            ForEach(plans) { plan in
                planCard(plan)
            }
        }
        .padding(.horizontal, theme.spacing.lg)
    }

    private func planCard(_ plan: PaywallPlanOption) -> some View {
        let isSelected = selectedPlanId == plan.id

        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedPlanId = plan.id
            }
        } label: {
            HStack(spacing: theme.spacing.md) {
                // Radio indicator
                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? theme.colors.primary : theme.colors.border,
                            lineWidth: isSelected ? 2 : 1.5
                        )
                        .frame(width: 22, height: 22)

                    if isSelected {
                        Circle()
                            .fill(theme.colors.primary)
                            .frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: theme.spacing.xxs) {
                    HStack(spacing: theme.spacing.sm) {
                        Text(plan.title)
                            .font(theme.typography.headline)
                            .fontWeight(theme.typography.emphasisWeight)
                            .foregroundColor(theme.colors.onSurface)

                        if plan.isBestValue {
                            Text("Best Value")
                                .font(theme.typography.caption2)
                                .fontWeight(theme.typography.heavyWeight)
                                .foregroundColor(.white)
                                .padding(.horizontal, theme.spacing.sm)
                                .padding(.vertical, theme.spacing.xxs)
                                .bgOverlay(bgColor: theme.colors.primary, radius: theme.shape.radiusFull)
                        }
                    }

                    if !plan.subtitle.isEmpty {
                        Text(plan.subtitle)
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.secondary)
                    }

                    if plan.isTrial, let trialDesc = plan.trialDescription {
                        Text(trialDesc)
                            .font(theme.typography.caption)
                            .foregroundColor(theme.colors.primary)
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: theme.spacing.xxs) {
                    Text(plan.priceDisplay)
                        .font(theme.typography.headline)
                        .fontWeight(theme.typography.heavyWeight)
                        .foregroundColor(theme.colors.onSurface)

                    Text(plan.period)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.secondary)
                }
            }
            .padding(theme.spacing.lg)
            .bgOverlay(
                bgColor: isSelected ? theme.colors.primary.opacity(0.06) : theme.colors.surface,
                radius: theme.shape.radiusMedium,
                borderColor: isSelected ? theme.colors.primary : theme.colors.borderSubtle,
                borderWidth: isSelected ? 2 : 1
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - CTA

    private var ctaSection: some View {
        VStack(spacing: theme.spacing.md) {
            ThemedButton(
                ctaLabel,
                role: .primary,
                fullWidth: true,
                isLoading: isLoading,
                disabled: selectedPlan == nil,
                action: {
                    guard let plan = selectedPlan else { return }
                    onPurchase(plan)
                }
            )
        }
        .padding(.horizontal, theme.spacing.lg)
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: theme.spacing.sm) {
            Button(action: onRestore) {
                Text("Restore Purchases")
                    .font(theme.typography.footnote)
                    .foregroundColor(theme.colors.secondary)
            }
            .buttonStyle(.plain)

            HStack(spacing: theme.spacing.md) {
                if let privacyURL = privacyURL {
                    Link("Privacy Policy", destination: privacyURL)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.secondary.opacity(0.7))
                }

                if privacyURL != nil && termsURL != nil {
                    Text("·")
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.secondary.opacity(0.5))
                }

                if let termsURL = termsURL {
                    Link("Terms of Use", destination: termsURL)
                        .font(theme.typography.caption)
                        .foregroundColor(theme.colors.secondary.opacity(0.7))
                }
            }
        }
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
                title: "Unlock Everything",
                subtitle: "Get unlimited access to all features",
                features: [
                    PaywallFeatureItem(
                        systemIcon: "chart.bar.fill",
                        iconColor: .blue,
                        title: "Advanced Analytics",
                        description: "Detailed progress tracking"
                    ),
                    PaywallFeatureItem(
                        systemIcon: "icloud.fill",
                        iconColor: .cyan,
                        title: "Cloud Sync",
                        description: "Access anywhere"
                    ),
                    PaywallFeatureItem(
                        systemIcon: "paintbrush.fill",
                        iconColor: .purple,
                        title: "Custom Themes",
                        description: "Make it yours"
                    ),
                ],
                plans: [
                    PaywallPlanOption(
                        id: "annual",
                        title: "Annual",
                        subtitle: "Save 50%",
                        priceDisplay: "$29.99",
                        period: "per year",
                        isBestValue: true,
                        isTrial: true,
                        trialDescription: "7-day free trial"
                    ),
                    PaywallPlanOption(
                        id: "monthly",
                        title: "Monthly",
                        priceDisplay: "$4.99",
                        period: "per month"
                    ),
                ],
                selectedPlanId: $selected,
                ctaLabel: "Start Free Trial",
                privacyURL: URL(string: "https://example.com/privacy"),
                termsURL: URL(string: "https://example.com/terms"),
                onPurchase: { _ in },
                onRestore: {},
                onDismiss: {}
            )
        }
    }
}
