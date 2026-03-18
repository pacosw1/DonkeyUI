import SwiftUI

// MARK: - OnboardingFlow

public struct OnboardingFlow: View {
    let pages: [OnboardingPageItem]
    let onComplete: () -> Void
    let onSkip: (() -> Void)?

    @State private var currentPage = 0
    @Environment(\.donkeyTheme) var theme

    public init(
        pages: [OnboardingPageItem],
        onComplete: @escaping () -> Void,
        onSkip: (() -> Void)? = nil
    ) {
        self.pages = pages
        self.onComplete = onComplete
        self.onSkip = onSkip
    }

    private var isLastPage: Bool {
        currentPage >= pages.count - 1
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Skip button
            HStack {
                Spacer()
                if !isLastPage, let onSkip = onSkip {
                    Button(action: onSkip) {
                        Text("Skip")
                            .font(theme.typography.subheadline)
                            .fontWeight(theme.typography.emphasisWeight)
                            .foregroundColor(theme.colors.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, theme.spacing.xl)
            .padding(.top, theme.spacing.md)
            .frame(height: 44)

            // Pages
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    pageView(page)
                        .tag(index)
                }
            }
            #if canImport(UIKit)
            .tabViewStyle(.page(indexDisplayMode: .never))
            #endif
            .animation(.easeInOut(duration: 0.3), value: currentPage)

            // Bottom controls
            VStack(spacing: theme.spacing.lg) {
                // Page indicators
                HStack(spacing: theme.spacing.sm) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentPage ? currentAccentColor : theme.colors.borderSubtle)
                            .frame(width: index == currentPage ? 24 : 8, height: 8)
                            .animation(.easeInOut(duration: 0.25), value: currentPage)
                    }
                }

                // Action button
                ThemedButton(
                    isLastPage ? "Get Started" : "Next",
                    icon: isLastPage ? "checkmark" : "arrow.right",
                    role: .primary,
                    fullWidth: true,
                    action: {
                        if isLastPage {
                            onComplete()
                        } else {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                    }
                )
                .padding(.horizontal, theme.spacing.lg)
            }
            .padding(.bottom, theme.spacing.xxl)
        }
        .background(theme.colors.background.ignoresSafeArea())
    }

    // MARK: - Page View

    private func pageView(_ page: OnboardingPageItem) -> some View {
        VStack(spacing: theme.spacing.xl) {
            Spacer()

            mediaView(page.media, accentColor: page.accentColor)

            VStack(spacing: theme.spacing.md) {
                Text(page.title)
                    .font(theme.typography.title)
                    .fontWeight(theme.typography.heavyWeight)
                    .foregroundColor(theme.colors.onBackground)
                    .multilineTextAlignment(.center)

                Text(page.description)
                    .font(theme.typography.body)
                    .foregroundColor(theme.colors.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, theme.spacing.xxl)

            Spacer()
            Spacer()
        }
    }

    @ViewBuilder
    private func mediaView(_ media: OnboardingMedia, accentColor: Color) -> some View {
        switch media {
        case .systemIcon(let name, let color):
            Image(systemName: name)
                .font(.system(size: 64))
                .fontWeight(.light)
                .foregroundColor(color)
                .frame(width: 120, height: 120)
                .bgOverlay(
                    bgColor: color.opacity(0.1),
                    radius: theme.shape.radiusXL
                )

        case .image(let name):
            Image(name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxHeight: 240)
                .clipShape(RoundedRectangle(cornerRadius: theme.shape.radiusMedium, style: .continuous))

        case .custom(let view):
            view
        }
    }

    private var currentAccentColor: Color {
        guard currentPage < pages.count else { return theme.colors.primary }
        return pages[currentPage].accentColor
    }
}

// MARK: - Preview

struct OnboardingFlow_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingFlow(
            pages: [
                OnboardingPageItem(
                    media: .systemIcon(name: "chart.bar.fill", color: .blue),
                    title: "Track Progress",
                    description: "See your daily, weekly, and monthly trends at a glance with beautiful charts.",
                    accentColor: .blue
                ),
                OnboardingPageItem(
                    media: .systemIcon(name: "bell.badge.fill", color: .orange),
                    title: "Stay on Track",
                    description: "Set smart reminders that adapt to your schedule and keep you motivated.",
                    accentColor: .orange
                ),
                OnboardingPageItem(
                    media: .systemIcon(name: "icloud.fill", color: .cyan),
                    title: "Sync Everywhere",
                    description: "Your data follows you across all your devices, always up to date.",
                    accentColor: .cyan
                ),
            ],
            onComplete: {},
            onSkip: {}
        )
    }
}
