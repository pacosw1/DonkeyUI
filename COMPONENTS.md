# DonkeyUI Component Catalog

> Auto-generated reference for AI assistants. Every public type is listed with its init signature and a usage example.

---

## Theme Setup

All DonkeyUI components read colors, typography, spacing, and shape from `DonkeyTheme` via the environment.
Apply a theme at the root of your view hierarchy:

```swift
@main
struct MyApp: App {
    let theme = DonkeyTheme(
        colors: DonkeyThemeColors(primary: .blue),
        typography: DonkeyThemeTypography(),
        shape: DonkeyThemeShape(),
        spacing: DonkeyThemeSpacing()
    )

    var body: some Scene {
        WindowGroup {
            ContentView()
                .donkeyTheme(theme)
        }
    }
}
```

### DonkeyTheme

Top-level theme container.

```swift
public init(
    colors: DonkeyThemeColors = DonkeyThemeColors(),
    typography: DonkeyThemeTypography = DonkeyThemeTypography(),
    shape: DonkeyThemeShape = DonkeyThemeShape(),
    spacing: DonkeyThemeSpacing = DonkeyThemeSpacing()
)
```

### DonkeyThemeColors

Semantic color palette.

```swift
public init(
    primary: Color = .accentColor,
    secondary: Color = .secondary,
    accent: Color = .accentColor,
    background: Color? = nil,        // defaults to systemBackground
    surface: Color? = nil,           // defaults to secondarySystemBackground
    surfaceElevated: Color? = nil,   // defaults to tertiarySystemBackground
    onPrimary: Color = .white,
    onSurface: Color? = nil,         // defaults to label
    onBackground: Color? = nil,      // defaults to label
    success: Color = .green,
    warning: Color = .orange,
    error: Color = .red,
    destructive: Color = .red,
    border: Color? = nil,            // defaults to separator
    borderSubtle: Color? = nil       // defaults to quaternarySystemFill
)
```

### DonkeyThemeTypography

Font scale and weight tokens.

```swift
public init(
    largeTitle: Font = .largeTitle,
    title: Font = .title,
    title2: Font = .title2,
    title3: Font = .title3,
    headline: Font = .headline,
    body: Font = .body,
    callout: Font = .callout,
    subheadline: Font = .subheadline,
    footnote: Font = .footnote,
    caption: Font = .caption,
    caption2: Font = .caption2,
    defaultWeight: Font.Weight = .regular,
    emphasisWeight: Font.Weight = .semibold,
    heavyWeight: Font.Weight = .bold
)
```

### DonkeyThemeShape

Corner radius tokens.

```swift
public init(
    radiusSmall: CGFloat = 5,
    radiusMedium: CGFloat = 12,
    radiusLarge: CGFloat = 18,
    radiusXL: CGFloat = 22,
    radiusFull: CGFloat = 999
)
```

### DonkeyThemeSpacing

Spacing scale tokens.

```swift
public init(
    xxs: CGFloat = 2,
    xs: CGFloat = 4,
    sm: CGFloat = 8,
    md: CGFloat = 12,
    lg: CGFloat = 16,
    xl: CGFloat = 24,
    xxl: CGFloat = 32,
    xxxl: CGFloat = 48
)
```

---

## Protocols & Data Models

### AccountDisplayInfo

User account info for `AccountCard`.

```swift
public init(
    displayName: String,
    email: String? = nil,
    avatarSystemIcon: String = "person.circle.fill",
    avatarURL: URL? = nil,
    memberSince: Date? = nil
)
```

### SubscriptionDisplayInfo

Subscription state for `SubscriptionCard` and `AccountCard`.

```swift
public init(
    planName: String,
    status: SubscriptionStatus = .unknown,  // .active, .trial, .expired, .cancelled, .free, .unknown
    expiresAt: Date? = nil,
    isTrial: Bool = false,
    renewsAutomatically: Bool = true,
    managementURL: URL? = nil
)
```

### SubscriptionStatus

```swift
public enum SubscriptionStatus: String {
    case active, trial, expired, cancelled, free, unknown
}
```

### OnboardingPageItem

Page data for `OnboardingFlow`.

```swift
public init(
    id: String = UUID().uuidString,
    media: OnboardingMedia,  // .systemIcon(name:color:), .image(name:), .custom(AnyView)
    title: String,
    description: String,
    accentColor: Color = .accentColor
)
```

### PaywallFeatureItem

Feature row for `FeatureGrid` and `PaywallScreen`.

```swift
public init(
    id: String = UUID().uuidString,
    systemIcon: String,
    iconColor: Color = .accentColor,
    title: String,
    description: String
)
```

### PaywallPlanOption

Plan option for `PaywallScreen`.

```swift
public init(
    id: String = UUID().uuidString,
    title: String,
    subtitle: String = "",
    priceDisplay: String,
    period: String,
    isBestValue: Bool = false,
    isTrial: Bool = false,
    trialDescription: String? = nil
)
```

### SettingsItem

Row data for `SettingsSection`.

```swift
public init(
    id: String = UUID().uuidString,
    systemIcon: String,
    iconColor: Color,
    title: String,
    subtitle: String? = nil,
    type: SettingsItemType,  // .toggle(isOn:), .navigation, .action(handler:), .info(value:), .destructiveAction(handler:)
    badge: String? = nil
)
```

### ChangelogEntry

Entry for `ChangelogView`.

```swift
public init(
    id: String = UUID().uuidString,
    version: String,
    date: Date,
    changes: [String]
)
```

### ToastItem

Data for `ToastView` and `.toast()` modifier.

```swift
public init(
    id: UUID = UUID(),
    type: ToastType,  // .success, .error, .warning, .info
    message: String
)
```

### NewFeatureItem

Row data for `WhatsNewView`.

```swift
public init(
    id: UUID = UUID(),
    icon: String,
    iconColor: Color,
    title: String,
    description: String
)
```

### TipJarOption

Option for `TipJarView`.

```swift
public init(label: String, price: Float)
```

### BarItem

Segment for `StackedChartView`.

```swift
public init(color: Color, amount: Double, name: String)
```

### TagItem (Protocol)

Conform to use with `ScrollTagSelector`.

```swift
public protocol TagItem: Identifiable {
    var internalId: UUID { get set }
    func getLabel() -> String
    func getColor() -> Color
    func getId() -> UUID
}
```

---

## Components (Themed)

### ThemedButton

Theme-aware button with primary/secondary/destructive roles.

```swift
public init(
    _ label: String,
    icon: String? = nil,
    role: ThemedButtonRole = .primary,  // .primary, .secondary, .destructive
    fullWidth: Bool = false,
    isLoading: Bool = false,
    disabled: Bool = false,
    action: @escaping () -> Void
)
```

```swift
ThemedButton("Get Started", icon: "arrow.right", role: .primary, action: { })
ThemedButton("Delete", role: .destructive, fullWidth: true, action: { })
```

### ThemedCard

Theme-aware card container with elevated/outlined/filled variants.

```swift
public init(
    variant: CardVariant = .elevated,  // .elevated, .outlined, .filled(Color)
    padding: CGFloat? = nil,
    @ViewBuilder content: @escaping () -> Content
)
```

```swift
ThemedCard(variant: .elevated) {
    Text("Card content")
}
```

### AccountCard

User account card with avatar, name, email, subscription badge.

```swift
public init(
    account: AccountDisplayInfo,
    subscription: SubscriptionDisplayInfo? = nil,
    onTap: (() -> Void)? = nil
)
```

```swift
AccountCard(
    account: AccountDisplayInfo(displayName: "Paco", email: "paco@example.com"),
    subscription: SubscriptionDisplayInfo(planName: "Pro", status: .active),
    onTap: { }
)
```

### SubscriptionCard

Subscription status card with upgrade/manage actions.

```swift
public init(
    subscription: SubscriptionDisplayInfo,
    onUpgrade: (() -> Void)? = nil,
    onManage: (() -> Void)? = nil
)
```

```swift
SubscriptionCard(
    subscription: SubscriptionDisplayInfo(planName: "Pro Monthly", status: .active),
    onManage: { }
)
```

### OnboardingFlow

Multi-page onboarding with page indicators and skip.

```swift
public init(
    pages: [OnboardingPageItem],
    onComplete: @escaping () -> Void,
    onSkip: (() -> Void)? = nil
)
```

```swift
OnboardingFlow(
    pages: [
        OnboardingPageItem(media: .systemIcon(name: "chart.bar.fill", color: .blue), title: "Track", description: "See your progress"),
    ],
    onComplete: { },
    onSkip: { }
)
```

### PaywallScreen

Server-driven paywall with hero headline, social proof, reviews carousel, emoji features, plan cards, and purchase flow. No RevenueCat dependency.

**Config types:**
```swift
PaywallConfig(headline:headlineAccent:subtitle:memberCount:rating:features:reviews:footerText:)
PaywallEmojiFeature(emoji:color:text:boldWord:)
PaywallReview(title:username:timeLabel:description:rating:)
```

```swift
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
)
```

```swift
PaywallScreen(
    config: PaywallConfig(
        headline: "GET YOUR SH*T",
        headlineAccent: "TOGETHER",
        subtitle: "Don't just track habits, turn your life around",
        memberCount: "50,000+ Members",
        rating: "4.6",
        features: [.init(emoji: "🏋️", color: .green, text: "habits", boldWord: "Unlimited")],
        reviews: [.init(title: "Perfect app", username: "User1", description: "Love it!")]
    ),
    plans: [PaywallPlanOption(id: "annual", title: "Annual", priceDisplay: "$29.99", period: "/year", isBestValue: true)],
    selectedPlanId: $selectedPlan,
    onPurchase: { plan in },
    onRestore: { },
    onDismiss: { }
)
```

### FeatureGrid

Grid of feature rows (used inside PaywallScreen or standalone).

```swift
public init(features: [PaywallFeatureItem], columns: Int = 1)
```

```swift
FeatureGrid(features: myFeatures, columns: 2)
```

### SettingsSection

Grouped settings rows with header/footer.

```swift
public init(header: String? = nil, footer: String? = nil, items: [SettingsItem])
```

```swift
SettingsSection(header: "General", items: [
    SettingsItem(systemIcon: "bell.fill", iconColor: .red, title: "Notifications", type: .toggle(isOn: $notifs)),
    SettingsItem(systemIcon: "star.fill", iconColor: .orange, title: "Rate App", type: .action(handler: { })),
])
```

### ListRow

Configurable list row with icon, title, subtitle, and accessory.

```swift
public init(
    icon: String? = nil,
    iconColor: Color = .accentColor,
    title: String,
    subtitle: String? = nil,
    accessory: ListRowAccessory = .none,  // .chevron, .toggle(Binding<Bool>), .badge(String, Color), .info(String), .none
    action: (() -> Void)? = nil
)
```

```swift
ListRow(icon: "bell.fill", iconColor: .red, title: "Notifications", accessory: .chevron, action: { })
```

### BannerView

Contextual banner for info/success/warning/error/promo messages.

```swift
public init(
    type: BannerType,  // .info, .success, .warning, .error, .promo
    message: String,
    actionLabel: String? = nil,
    onAction: (() -> Void)? = nil,
    onDismiss: (() -> Void)? = nil
)
```

```swift
BannerView(type: .success, message: "Saved!", onDismiss: { })
```

### ToastView

Notification toast (use with `.toast()` modifier).

```swift
public init(item: ToastItem)
```

```swift
// Via modifier:
.toast(item: $toastItem)

// Trigger:
toastItem = ToastItem(type: .success, message: "Done!")
```

### EmptyStateView

Placeholder for empty lists/screens with optional CTA.

```swift
public init(
    systemIcon: String,
    title: String,
    description: String? = nil,
    ctaLabel: String? = nil,
    ctaAction: (() -> Void)? = nil
)
```

```swift
EmptyStateView(systemIcon: "tray", title: "No Items", description: "Add your first item.", ctaLabel: "Add", ctaAction: { })
```

### DonkeySearchBar

Search bar with debounce, clear button, and cancel.

```swift
public init(
    text: Binding<String>,
    placeholder: String = "Search",
    showCancel: Bool = true,
    onSubmit: (() -> Void)? = nil
)
```

```swift
DonkeySearchBar(text: $query, placeholder: "Search products...")
```

### SegmentedPicker

Animated segmented control for any `CaseIterable & CustomStringConvertible` enum.

```swift
public init(selection: Binding<T>)
```

```swift
// enum Tab: String, CaseIterable, CustomStringConvertible { case daily, weekly; var description: String { rawValue } }
SegmentedPicker<Tab>(selection: $selectedTab)
```

### DonkeyConfirmationDialog

Modal confirmation dialog with destructive support.

```swift
public init(
    isPresented: Binding<Bool>,
    title: String,
    message: String? = nil,
    confirmLabel: String = "Confirm",
    cancelLabel: String = "Cancel",
    isDestructive: Bool = false,
    onConfirm: @escaping () -> Void
)
```

```swift
// Via modifier:
.donkeyConfirmation(isPresented: $showDelete, title: "Delete?", isDestructive: true, onConfirm: { })
```

### DonkeyBottomSheet

Draggable bottom sheet with medium/large detents.

```swift
public init(
    isPresented: Binding<Bool>,
    detent: SheetDetent = .medium,  // .medium (50%), .large (90%)
    @ViewBuilder content: @escaping () -> Content
)
```

```swift
// Via modifier:
.donkeySheet(isPresented: $showSheet, detent: .medium) {
    Text("Sheet content")
}
```

### LoadingOverlay

Full-screen loading overlay with spinner and message.

```swift
public init(isPresented: Binding<Bool>, message: String? = nil)
```

```swift
.loadingOverlay(isPresented: $isLoading, message: "Saving...")
```

### CountdownView

Live countdown timer with day/hour/minute/second blocks.

```swift
public init(
    targetDate: Date,
    label: String? = nil,
    onExpired: (() -> Void)? = nil
)
```

```swift
CountdownView(targetDate: saleEndDate, label: "Sale Ends")
```

### DonkeyDivider

Themed divider with optional centered label.

```swift
public init(label: String? = nil, color: Color? = nil, thickness: CGFloat = 1)
```

```swift
DonkeyDivider(label: "or")
```

### KeyValueRow

Label-value row with optional icon and copy button.

```swift
public init(label: String, value: String, systemIcon: String? = nil, copiable: Bool = false)
```

```swift
KeyValueRow(label: "Email", value: "user@example.com", systemIcon: "envelope", copiable: true)
```

### ReviewCard

App Store review card with star rating.

```swift
public init(authorName: String, rating: Int, title: String? = nil, bodyText: String, date: Date? = nil)
```

```swift
ReviewCard(authorName: "Sarah K.", rating: 5, title: "Love it!", bodyText: "Great app.", date: Date())
```

### RatingPromptView

Two-phase rating prompt (positive -> App Store, negative -> feedback).

```swift
public init(
    appName: String,
    onPositive: @escaping () -> Void,
    onNegative: @escaping () -> Void,
    onDismiss: @escaping () -> Void
)
```

```swift
RatingPromptView(appName: "MyApp", onPositive: { }, onNegative: { }, onDismiss: { })
```

### NotificationPermissionView

Full-screen notification permission request.

```swift
public init(
    title: String = "Stay in the Loop",
    description: String = "Get notified about what matters most to you.",
    features: [String],
    onEnable: @escaping () -> Void,
    onSkip: @escaping () -> Void
)
```

```swift
NotificationPermissionView(features: ["Daily reminders", "Weekly reports"], onEnable: { }, onSkip: { })
```

### ChangelogView

Scrollable version history.

```swift
public init(entries: [ChangelogEntry])
```

```swift
ChangelogView(entries: [
    ChangelogEntry(version: "2.4.0", date: Date(), changes: ["Dark mode", "Bug fixes"])
])
```

### AsyncCachedImage

Cached async image loader with shimmer placeholder.

```swift
public init(url: URL?, placeholder: AnyView? = nil, cornerRadius: CGFloat = 8)
```

```swift
AsyncCachedImage(url: imageURL, cornerRadius: 16)
    .frame(width: 120, height: 120)
```

### AvatarView

Avatar with image URL, initials fallback, or icon fallback.

```swift
public init(
    name: String? = nil,
    imageURL: URL? = nil,
    systemIcon: String = "person.fill",
    size: AvatarSize = .medium,  // .small(32), .medium(44), .large(64), .xl(80)
    color: Color? = nil
)
```

```swift
AvatarView(name: "John Doe", size: .large, color: .blue)
```

### StatusBadge

Colored status pill.

```swift
public init(label: String, style: BadgeStyle)  // .active, .trial, .expired, .cancelled, .custom(Color)
```

```swift
StatusBadge(label: "Active", style: .active)
```

### StepperInput

Themed +/- stepper with animated value display.

```swift
public init(value: Binding<Int>, range: ClosedRange<Int> = 0...100, step: Int = 1, label: String? = nil)
```

```swift
StepperInput(value: $quantity, range: 1...10, label: "Quantity")
```

### StickyHeaderScrollView

Scroll view with a collapsible sticky header.

```swift
public init(
    minHeight: CGFloat = 60,
    maxHeight: CGFloat = 260,
    @ViewBuilder header: @escaping () -> Header,
    @ViewBuilder content: @escaping () -> Content
)
```

```swift
StickyHeaderScrollView(minHeight: 80, maxHeight: 280) {
    LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
} content: {
    ForEach(items) { item in Text(item.name) }
}
```

---

## Buttons

### ButtonView

Low-level button with filled/bordered/text/card styles.

```swift
public init(
    label: String,
    icon: String? = nil,
    color: Color = .accentColor,
    buttonType: ButtonType = .filled,  // .filled, .bordered, .text, .card
    padding: CGFloat = 1.5,
    font: Font = .body,
    fontWeight: Font.Weight = .heavy,
    fullWidth: Bool = false,
    disabled: Bool = false,
    radius: CGFloat = 12,
    isLoading: Bool = false,
    action: @escaping () -> Void = {}
)
```

```swift
ButtonView(label: "Start", icon: "play.fill", color: .blue, buttonType: .filled, action: { })
```

### CheckButtonView

Animated checkbox indicator.

```swift
public init(active: Bool, size: ButtonSize = .medium, color: Color = .accentColor)
// ButtonSize: .tiny(10), .verySmall(15), .small(20), .medium(25), .large(30)
```

```swift
CheckButtonView(active: isChecked, size: .medium, color: .blue)
```

### CloseButton

Circular X close button.

```swift
public init(size: ButtonSize = .medium, action: @escaping () -> Void)
```

```swift
CloseButton(action: { dismiss() })
```

### FloatingActionButton (modifier)

Floating action button overlay.

```swift
.floatingActionButton(systemIcon: "plus", action: { }, hidden: false)
```

---

## Icons

### IconView

SF Symbol in a colored rounded-rect background.

```swift
public init(
    image: String,
    color: Color,
    size: IconSize = .large,  // .micro(10), .tiny(25), .verySmall(30), .small(35), .medium(40), .large(45), .veryLarge(50), .huge(70)
    inverted: Bool = false
)
```

```swift
IconView(image: "star.fill", color: .orange, size: .medium)
```

### IconRowView

Icon + label + badge count row.

```swift
public init(icon: String, label: String, color: Color, badgeCount: Int, badgeColor: Color = .pink, inverted: Bool = false)
```

```swift
IconRowView(icon: "heart.fill", label: "Favorites", color: .pink, badgeCount: 3)
```

### CalendarIconView

Mini calendar icon showing a date number.

```swift
public init(date: Date, dots: Bool = false)
```

```swift
CalendarIconView(date: Date())
```

### ReminderIconView

Time option selector button (e.g., "5 Min", "1 Hour").

```swift
public init(timeLabel: String, optionLabel: String, selected: Bool, small: Bool = false)
```

```swift
ReminderIconView(timeLabel: "5", optionLabel: "Min", selected: true)
```

---

## Tags

### TagView

Colored tag pill with optional delete button.

```swift
public init(
    id: UUID,
    title: String,
    color: Color,
    dull: Bool = false,
    delete: Bool = false,
    deleteAction: @escaping (UUID) -> Void = { _ in },
    holdAction: @escaping () -> Void = {},
    selected: Bool = false,
    verySmall: Bool = false
)
```

```swift
TagView(id: UUID(), title: "Work", color: .blue, selected: true)
```

### ScrollTagSelector

Horizontally scrolling tag picker conforming to `TagItem` protocol.

```swift
public init(selected: Binding<(any TagItem)?>, tags: [any TagItem])
```

```swift
ScrollTagSelector(selected: $selectedTag, tags: myTags)
```

---

## Badge

### BadgeLabelView

Numeric badge pill.

```swift
public init(count: Int, color: Color = .pink)
```

```swift
BadgeLabelView(count: 5, color: .red)
```

### .badgeCount() modifier

Overlay a badge count on any view.

```swift
.badgeCount(_ count: Int)
```

```swift
Image(systemName: "bell.fill").badgeCount(3)
```

---

## Progress

### CircularProgressView

Circular progress ring with checkmark on completion.

```swift
public init(color: Color = .blue, delay: Double = 0.0, progress: CGFloat, size: CGFloat)
```

```swift
CircularProgressView(color: .blue, progress: 0.75, size: 40)
```

### ProgressBarView

Horizontal progress bar.

```swift
public init(width: CGFloat = 100.0, fullWidth: Bool = false, progress: CGFloat)
```

```swift
ProgressBarView(fullWidth: true, progress: 0.6)
```

### ProgressStepperView

Step indicator with numbered circles and connecting line.

```swift
public init(steps: Int, currentStep: Binding<Int>, lineHeight: CGFloat = 5, color: Color = .accentColor)
```

```swift
ProgressStepperView(steps: 5, currentStep: $step)
```

### SpinnerLoadingView

Spinning loading indicator.

```swift
public init(color: Color = .accentColor, disabled: Bool = false, size: CGFloat = 25, lineWidth: CGFloat = 5)
```

```swift
SpinnerLoadingView(color: .blue, size: 40, lineWidth: 4)
```

### ProgressIcon

SF Symbol filled with animated wave to show progress.

```swift
public init(progress: CGFloat, icon: String = "trophy.fill", iconSize: CGFloat = 40, color: Color = .black, shape: any Shape = Circle())
```

```swift
ProgressIcon(progress: 0.6, icon: "drop.fill", iconSize: 80, color: .blue)
```

### PieChartView

Interactive donut/pie chart.

```swift
public init(
    values: [Double],
    names: [String],
    formatter: @escaping (Double) -> String,
    colors: [Color] = [.blue, .green, .orange],
    backgroundColor: Color = Color(red: 21/255, green: 24/255, blue: 30/255),
    widthFraction: CGFloat = 0.75,
    innerRadiusFraction: CGFloat = 0.60
)
```

```swift
PieChartView(values: [300, 500, 200], names: ["A", "B", "C"], formatter: { "\(Int($0))" })
```

### StackedChartView

Horizontal stacked bar chart with legend.

```swift
public init(barItems: [BarItem], height: CGFloat = 25)
```

```swift
StackedChartView(barItems: [
    BarItem(color: .blue, amount: 300, name: "Social"),
    BarItem(color: .pink, amount: 140, name: "Health"),
])
```

---

## Skeleton / Loading

### .skeleton() modifier

Shimmer-animated redacted placeholder.

```swift
.skeleton(isLoading: Bool)
```

```swift
Text("Loading...").skeleton(isLoading: true)
```

### SkeletonRow

Pre-built skeleton row with avatar + text lines.

```swift
public init(lineCount: Int = 2)  // 1-3
```

```swift
SkeletonRow(lineCount: 2)
```

---

## Settings Views

### SettingToggleView

Toggle row with icon for settings screens.

```swift
public init(isOn: Binding<Bool>, label: String, systemIcon: String, iconColor: Color, caption: String = "")
```

```swift
SettingToggleView(isOn: $darkMode, label: "Dark Mode", systemIcon: "moon.fill", iconColor: .indigo)
```

### UseBiometricsToggle

Auto-detecting Face ID / Touch ID toggle.

```swift
public init()
```

```swift
UseBiometricsToggle()
```

### DailyReminderView

Daily reminder time picker with notification scheduling.

```swift
public init()
```

```swift
DailyReminderView()
```

### LeaveReviewView

"Leave a Review" row that opens the App Store.

```swift
public init(url: String)
```

```swift
LeaveReviewView(url: "https://apps.apple.com/app/id123456?action=write-review")
```

### AppIdView

Displays an app/user ID string.

```swift
public init(id: String)
```

```swift
AppIdView(id: userCloudId)
```

### FeedbackView

Feedback form with submission and "sent" confirmation.

```swift
public init(onSubmit: @escaping (String, String) -> Void)
```

```swift
FeedbackView(onSubmit: { text, email in sendFeedback(text, email) })
```

---

## Views

### WhatsNewView

What's New feature showcase with icon grid.

```swift
public init(title: String = "What's New", items: [NewFeatureItem] = [], action: @escaping () -> Void)
```

```swift
WhatsNewView(items: [
    NewFeatureItem(icon: "star.fill", iconColor: .blue, title: "New Feature", description: "Details here"),
], action: { dismiss() })
```

### TipJarView

Tip jar with selectable amounts.

```swift
public init(
    titleIcon: String,
    options: [TipJarOption],
    titleLabel: String,
    titleDescription: String,
    confirmPurchaseLabel: String,
    optionalDisclaimer: String? = nil,
    purchaseAction: @escaping () -> Void,
    closeAction: @escaping () -> Void,
    selected: UUID = UUID()
)
```

```swift
TipJarView(
    titleIcon: "heart.fill",
    options: [TipJarOption(label: "Coffee", price: 2.99), TipJarOption(label: "Pizza", price: 9.99)],
    titleLabel: "Support Development",
    titleDescription: "Optional tips keep the app alive!",
    confirmPurchaseLabel: "Confirm Tip",
    purchaseAction: { },
    closeAction: { }
)
```

### NumberPadInput

Custom number pad for numeric input.

```swift
public init(label: Binding<String>, submitAction: @escaping (Double) -> Void)
```

```swift
NumberPadInput(label: $amount, submitAction: { value in save(value) })
```

### OnboardingPanelView

Step-based onboarding with progress stepper and slides.

```swift
public init(views: [SlideView])
```

```swift
OnboardingPanelView(views: [
    SlideView(view: StepOneView(), icon: "1.circle.fill", title: "Step 1"),
    SlideView(view: StepTwoView(), icon: "2.circle.fill", title: "Step 2"),
])
```

### ColorPickerView

Grid color picker.

```swift
public init(
    colors: [Color] = [.pink, .orange, .blue, .indigo, .green, .mint, .purple, .cyan, .brown, .black, .gray],
    selected: Binding<Color>,
    verticalSpacing: CGFloat = 10,
    horizontalSpacing: CGFloat = 40
)
```

```swift
ColorPickerView(colors: [.blue, .green, .purple], selected: $selectedColor)
```

### PagerView

Swipeable horizontal pager.

```swift
public init(swipeAction: @escaping (Bool) -> Void, page: Binding<Int>, views: [SwipableView] = [])
```

```swift
PagerView(swipeAction: { forward in }, page: $currentPage, views: [
    SwipableView(view: AnyView(Page1())),
    SwipableView(view: AnyView(Page2())),
])
```

### CloudkitStatusView

iCloud diagnostics screen showing account, network, space status.

```swift
public init(/* all params have defaults */)
```

```swift
NavigationLink("iCloud Status") { CloudkitStatusView() }
```

### BiometricLockView

Lock screen requiring Face ID / Touch ID.

```swift
// Use via modifier:
.biometricLock(enabled: Bool = true)
```

```swift
ContentView()
    .biometricLock(enabled: useBiometrics)
```

---

## View Modifiers

### .bgOverlay()

Background + border overlay (the foundational modifier used by most components).

```swift
.bgOverlay(bgColor: Color, radius: CGFloat = 5.0, borderColor: Color = .clear, borderWidth: CGFloat = 1.0)
```

### .card()

Card-style background with padding.

```swift
.card(transparent: Bool = false, color: Color = secondaryBackground, padding: CGFloat = 1, radius: BorderRadius = .card)
// BorderRadius: .slightly(5), .card(12), .bottomMenu(18), .round(22)
```

### .bordered()

Background fill with rounded corners.

```swift
.bordered(color: Color = secondaryBackground, radius: BorderRadius = .card)
```

### .fullscreen()

Full-screen background color.

```swift
.fullscreen(bgColor: Color = secondaryBackground, dim: Bool = false)
```

### .hidden()

Conditionally hide a view (replaces with EmptyView).

```swift
.hidden(_ hidden: Bool = false)
```

### .selected()

Selection border + fill highlight.

```swift
.selected(_ selected: Bool, radius: CGFloat = 5, border: Bool = true, fill: Bool = true, color: Color = .accentColor)
```

### .checkbox()

Prepend a checkbox to any view.

```swift
.checkbox(isOn: Binding<Bool>, color: Color = .accentColor, disabled: Bool, action: @escaping () -> Void)
```

### .editToggle()

Expandable section with icon, label, and toggle sheet.

```swift
.editToggle(isOn: Binding<Bool>, startExpanded: Bool = false, systemImage: String, label: String, iconColor: Color, secondaryLabel: String = "")
```

### .errorToast()

Error toast overlay (requires PopupView package).

```swift
.errorToast(errorMessage: String = "Connection Error", presented: Binding<Bool>)
```

### .floatingMenuSheet()

Floating bottom sheet overlay.

```swift
.floatingMenuSheet(isPresented: Binding<Bool>, @ViewBuilder content: () -> View, position: CardPosition = .center, paddingBottom: CGFloat = 0, drag: Bool = true)
```

### .expandable()

Tap-to-expand card modifier.

```swift
.expandable(expanded: Bool, @ViewBuilder customView: () -> View)
```

### .cornerRadius(_:corners:)

Round specific corners only.

```swift
.cornerRadius(_ radius: CGFloat, corners: UIRectCorner)  // iOS
.cornerRadius(_ radius: CGFloat, corners: RectCorner)     // macOS
```

### .wiggling()

Continuous wiggle animation (for edit mode).

```swift
.wiggling()
```

### .searchMod()

Pull-to-search scroll wrapper.

```swift
.searchMod(onPull: @escaping () -> Void = {})
```

### .sheetNavigation()

Wraps content in a NavigationView with Cancel/Submit toolbar items.

```swift
.sheetNavigation(header: String, submitLabel: String, submitDisabled: Bool, submitAction: @escaping () -> Void)
```

### .onDebounce()

Debounced onChange handler.

```swift
.onDebounce(of: value, duration: .milliseconds(300)) { performSearch() }
```

---

## Helpers

### DonkeyHaptics

Cross-platform haptic feedback.

```swift
DonkeyHaptics.light()
DonkeyHaptics.medium()
DonkeyHaptics.heavy()
DonkeyHaptics.success()
DonkeyHaptics.warning()
DonkeyHaptics.error()
DonkeyHaptics.selection()
```

### DonkeyDateFormatter

Date formatting utility.

```swift
DonkeyDateFormatter.format(date, style: .relative)    // "2h ago"
DonkeyDateFormatter.format(date, style: .short)        // "Mar 18"
DonkeyDateFormatter.format(date, style: .medium)       // "March 18, 2026"
DonkeyDateFormatter.format(date, style: .long)         // "Tuesday, March 18, 2026"
DonkeyDateFormatter.format(date, style: .memberSince)  // "Member since March 2024"
DonkeyDateFormatter.format(date, style: .expiresOn)    // "Expires March 18, 2026"
```

### DonkeyCurrencyFormatter

Localized currency formatting.

```swift
DonkeyCurrencyFormatter.format(9.99, currencyCode: "USD")   // "$9.99"
DonkeyCurrencyFormatter.formatCents(999, currencyCode: "USD") // "$9.99"
```

### AppReviewManager

Smart review prompt manager with configurable thresholds.

```swift
AppReviewManager.trackAppOpen()                    // Call on every launch
AppReviewManager.shouldPromptForReview() -> Bool   // Check if eligible
AppReviewManager.requestReview()                   // Show App Store review dialog
AppReviewManager.reset()                           // Reset for testing

// Configure thresholds:
AppReviewManager.minimumAppOpens = 10
AppReviewManager.minimumDaysSinceInstall = 7
AppReviewManager.minimumDaysBetweenPrompts = 90
```

### Debouncer

Actor-based async debouncer.

```swift
let debouncer = Debouncer(duration: .milliseconds(300))
await debouncer.debounce { await performSearch(query) }
```

### EmailValidator

Email format validation and sanitization.

```swift
EmailValidator.isValid("user@example.com")  // true
EmailValidator.sanitize("  User@EXAMPLE.com  ")  // "user@example.com"
```

### KeychainHelper

Simple keychain storage for tokens and secrets.

```swift
KeychainHelper.save(key: "auth_token", value: "abc123")
let token = KeychainHelper.load(key: "auth_token")
KeychainHelper.update(key: "auth_token", value: "xyz789")
KeychainHelper.delete(key: "auth_token")
```

### NetworkMonitor

Observable network connectivity monitor.

```swift
@ObservedObject private var network = NetworkMonitor.shared

if !network.isConnected { Text("Offline") }
network.connectionType  // .wifi, .cellular, .ethernet, .unknown
```

### DeviceInfo

Device and app metadata.

```swift
DeviceInfo.modelName       // "iPhone 16 Pro"
DeviceInfo.systemVersion   // "18.2.1"
DeviceInfo.isPhone         // true
DeviceInfo.isPad           // false
DeviceInfo.isMac           // false
DeviceInfo.appVersion      // "2.4.0"
DeviceInfo.buildNumber     // "42"
```

### UnitFormatter

Locale-aware unit formatting for liquids and numbers.

```swift
UnitFormatter.formatLiquid(500, unit: .milliliters)       // "500 ml"
UnitFormatter.formatLiquid(500, unit: .fluidOunces)       // "16.9 fl oz"
UnitFormatter.convert(500, from: .milliliters, to: .cups) // 2.11...
UnitFormatter.compact(1234567)                             // "1.2M"
UnitFormatter.withUnit(1234, unit: "steps")                // "1,234 steps"
UnitFormatter.percentage(0.756, decimals: 1)               // "75.6%"
```

Units: `.milliliters`, `.liters`, `.fluidOunces`, `.cups`, `.gallons`

### SoundManager

Simple sound player with user preference toggle.

```swift
SoundManager.play("pop.aif")                // play bundle sound
SoundManager.play("success.mp3", volume: 0.5)
SoundManager.playSystem(1057)               // system sound ID
SoundManager.isEnabled                      // reads UserDefaults
SoundManager.setEnabled(false)              // toggle off
```

### AccessibilityHelper

Accessibility state detection.

```swift
AccessibilityHelper.prefersReducedMotion  // Bool
AccessibilityHelper.isVoiceOverRunning    // Bool
AccessibilityHelper.prefersLargeText      // Bool
AccessibilityHelper.prefersBoldText       // Bool

// Modifier: skip animation when reduced motion is on
.animateUnlessReduced(.spring(), value: isActive)
```

---

## Effects

### DonkeyConfettiView

80-particle confetti burst using Canvas + TimelineView.

```swift
DonkeyConfettiView(colors: [.blue, .pink, .yellow], particleCount: 80)

// Modifier — fires when trigger becomes true:
.confetti(trigger: showConfetti, colors: [.blue, .pink, .green])
```

### DonkeySparkleView

Looping 4-pointed star sparkle effect.

```swift
DonkeySparkleView(isActive: true, centerX: 100, centerY: 100, radius: 90)
```

### DonkeyGlowRingView

Pulsing radial gradient glow.

```swift
DonkeyGlowRingView(isActive: goalReached, size: 240, color: .yellow)
```

### CelebrationModifier

Combined confetti + sparkle + glow + optional sound. Auto-dismisses after 3s.

```swift
.celebration(isActive: $goalReached, sound: "pop.aif")
```

### FluidFillView

Realistic water simulation with device tilt. Spring-damper physics, Catmull-Rom rendering, shake detection, haptic feedback.

```swift
public init(
    fillPercent: Double,          // 0...1
    color: Color = .accentColor,
    enableMotion: Bool = true,
    iconSize: CGFloat = 200,
    completionColor: Color? = nil,
    showCheckmark: Bool = false,
    maskImage: String? = nil       // SF Symbol name, nil = "drop.fill"
)
```

```swift
// Standalone
FluidFillView(fillPercent: 0.7, color: .blue, iconSize: 200, maskImage: "drop.fill")

// Any shape mask
FluidFillView(fillPercent: progress, maskImage: "heart.fill")

// Modifier
Circle()
    .fluidFill(fillPercent: 0.6, color: .cyan)
```

### AnimatedNumberView

Smooth number transitions with `.contentTransition(.numericText())`.

```swift
public init(
    value: Double,
    format: AnimatedNumberFormat = .integer,
    font: Font = .title,
    fontWeight: Font.Weight = .bold,
    color: Color? = nil
)
```

Formats: `.integer`, `.decimal(2)`, `.currency("USD")`, `.percentage`, `.compact`

```swift
AnimatedNumberView(value: 1234.5, format: .currency("USD"), font: .largeTitle)
AnimatedNumberView(value: progress, format: .percentage)
AnimatedNumberView(value: followers, format: .compact)
```

---

## Gradient Presets

```swift
LinearGradient.sunrise   // orange → yellow → light
LinearGradient.ocean     // deep blue → cyan → light blue
LinearGradient.sunset    // purple → pink → orange
LinearGradient.forest    // dark green → green → mint
LinearGradient.berry     // purple → magenta → pink
LinearGradient.gold      // dark gold → gold → light gold
LinearGradient.midnight  // near-black → dark blue → indigo
LinearGradient.lavender  // purple → lavender → light purple
```

---

## Sync

### SyncStatusView

Full cloud sync management screen with status, storage, item counts, and actions.

**Data types:**
```swift
SyncState: .idle, .syncing(progress:completed:total:), .upToDate(lastSynced:), .error(message:lastSynced:)
SyncStorageInfo(usedBytes: Int, limitBytes: Int, tier: String, tierLabel: String)
SyncItemCount(label: String, systemIcon: String, count: Int, limit: Int?)
SyncStatusData(state:storage:items:userLabel:)
```

```swift
public init(
    data: SyncStatusData,
    onSync: (() async -> Void)? = nil,
    onFullSync: (() async -> Void)? = nil,
    onUpgrade: (() -> Void)? = nil
)
```

```swift
SyncStatusView(
    data: SyncStatusData(
        state: .upToDate(lastSynced: lastSync),
        storage: SyncStorageInfo(usedBytes: 3_500_000, limitBytes: 10_485_760, tier: "free", tierLabel: "Free"),
        items: [
            SyncItemCount(label: "Tasks", systemIcon: "checkmark.circle", count: 42, limit: 100),
            SyncItemCount(label: "Lists", systemIcon: "list.bullet", count: 5, limit: 10),
        ],
        userLabel: "paco@example.com"
    ),
    onSync: { await syncService.sync() },
    onFullSync: { await syncService.fullSync() },
    onUpgrade: { showPaywall = true }
)
```

### SyncStatusRow

Compact sync status row for settings lists. Green/orange/gray dot + label + last synced.

```swift
public init(state: SyncState, onTap: (() -> Void)? = nil)
```

```swift
SyncStatusRow(state: .upToDate(lastSynced: .now)) { navigateToSyncDetails() }
SyncStatusRow(state: .syncing(progress: 0.5, completed: 10, total: 20))
SyncStatusRow(state: .error(message: "Connection failed", lastSynced: nil))
```

---

## Store (StoreKit 2)

### DonkeyStoreManager

Universal StoreKit 2 manager with multi-tier support. No hardcoded product IDs or API clients.

```swift
public init(config: StoreConfig, callbacks: StoreCallbacks = StoreCallbacks())
```

**Simple config (single tier):**
```swift
StoreConfig(productIDs: ["com.app.monthly", "com.app.yearly"])
```

**Multi-tier config (free / premium / pro):**
```swift
StoreConfig(
    tiers: [
        StoreTier(name: "premium", productIDs: ["lifetime_deal"], features: ["unlimited_local"]),
        StoreTier(name: "pro", productIDs: ["month", "yearly"], features: ["unlimited_local", "cloud", "ai"]),
    ],
    promoProductIDs: ["month_promo", "yearly_promo"],  // maps to highest tier
    userDefaultsSuite: "group.com.app"                  // for widgets
)
```

**StoreTier:**
```swift
StoreTier(name: String, productIDs: Set<String>, features: Set<String>, priority: Int? = nil)
```

**StoreCallbacks:**
```swift
StoreCallbacks(
    onPurchaseComplete: { transaction, product in await api.sync(tx) },
    onRestoreComplete: { productIDs in },
    onSubscriptionChange: { productID, status, expiresAt in }
    // status: "pro", "premium", "free", "pro_trial", "pro_grace_period", "pro_billing_retry"
)
```

**Usage:**
```swift
let store = DonkeyStoreManager(
    config: StoreConfig(tiers: [
        StoreTier(name: "premium", productIDs: ["lifetime"], features: ["unlimited_local"]),
        StoreTier(name: "pro", productIDs: ["month", "yearly"], features: ["unlimited_local", "cloud", "ai"]),
    ]),
    callbacks: StoreCallbacks(onPurchaseComplete: { tx, product in await api.sync(tx) })
)
ContentView().environment(store)

@Environment(DonkeyStoreManager.self) var store

// Tier access
store.isPro                       // Bool — any paid tier (backwards compatible)
store.currentTier                 // "pro", "premium", or "free"
store.isSubscriber                // true if active auto-renewable subscription
store.isLifetimePurchaser         // true if non-consumable lifetime
store.hasFeature("cloud")         // true only for pro tier
store.hasFeature("unlimited_local") // true for both premium and pro
store.premiumCheck(feature: "ai") { runAI() }  // runs action or shows paywall

// Paywall state (bindable)
store.showPaywall                 // Bool — bind to .fullScreenCover
store.showPromoPaywall            // Bool — for promo flows

// Products
store.products                    // [Product] sorted yearly > monthly > lifetime
store.subscriptionProducts        // auto-renewable only
store.promoProducts               // loaded separately via loadPromoProducts()
await store.loadPromoProducts()   // -> [Product]

// Purchase
await store.purchase(product)     // -> PurchaseResult
await store.restore()             // -> Bool
store.isPurchasing                // Bool
store.error                       // String?

// Subscription details
store.activeSubscription          // .productID, .expirationDate, .isInTrial, .willAutoRenew,
                                  // .isInGracePeriod, .isInBillingRetry, .originalTransactionID

// Debug (DEBUG only)
store.debugGrantPro()
store.debugClearPurchases()
store.debugSetTier("premium")     // test specific tier

// Helpers
DonkeyStoreManager.savingsPercentage(yearly: p1, monthly: p2)  // -> Int? (e.g. 55)
DonkeyStoreManager.monthlyEquivalent(yearlyProduct)             // -> Decimal?
```

### ProFeatureGate

Locks content behind pro. Shows upgrade prompt or dims + intercepts taps.

```swift
// As a view:
ProFeatureGate(store: store, showPaywall: $showPaywall) {
    Text("Pro-only content here")
}

// As a modifier (dims + intercepts taps):
Button("Export") { export() }
    .proGated(store: store, showPaywall: $showPaywall)
```

---

## Auth (Apple Sign In)

### DonkeyAuthManager

Apple Sign In with Keychain persistence and server sync callbacks.

```swift
public init(
    keychainService: String,               // your bundle ID
    keychainKey: String = "donkey-auth-user",
    callbacks: AuthCallbacks = AuthCallbacks()
)
```

**AuthCallbacks:**
```swift
AuthCallbacks(
    onSignIn: { user, idToken in
        let resp = try? await api.signIn(token: idToken, name: user.name ?? "")
        return resp?.user.name  // return server name if available
    },
    onSignOut: { await api.logout() }
)
```

**DonkeyAuthUser:**
```swift
DonkeyAuthUser(id: String, email: String, name: String?, createdAt: Date?)
```

**Usage:**
```swift
let auth = DonkeyAuthManager(
    keychainService: "com.waterfullapp",
    callbacks: AuthCallbacks(onSignIn: { user, token in ... })
)
ContentView().environment(auth)

@Environment(DonkeyAuthManager.self) var auth
auth.isAuthenticated   // Bool
auth.user              // DonkeyAuthUser?
auth.isLoading         // Bool
auth.errorMessage      // String?
auth.signOut()
```

### AppleSignInView

Themed drop-in Apple Sign In screen.

```swift
public init(
    auth: DonkeyAuthManager,
    appName: String,
    appIcon: String = "app.fill",
    features: [String] = [],
    privacyURL: URL? = nil,
    termsURL: URL? = nil,
    onSkip: (() -> Void)? = nil
)
```

```swift
AppleSignInView(
    auth: auth,
    appName: "Waterful",
    appIcon: "drop.fill",
    features: ["Sync across devices", "Smart reminders", "Track progress"],
    privacyURL: URL(string: "https://example.com/privacy")
)

// Or gate content with modifier:
ContentView()
    .requireAuth(auth: auth, appName: "Waterful", appIcon: "drop.fill",
                 features: ["Sync across devices"])
```

---

## Onboarding

### OnboardingManager

Tracks onboarding completion, first launch, version-based re-onboarding, and section-level progress for immersive flows.

```swift
public init(
    suite: String? = nil,                          // App Group suite for widgets
    completedKey: String = "donkey_onboarding_completed",
    versionKey: String = "donkey_onboarding_version",
    sectionsKey: String = "donkey_onboarding_sections"
)
```

```swift
let onboarding = OnboardingManager(suite: "group.com.myapp")

onboarding.hasCompleted           // Bool
onboarding.isFirstLaunch          // Bool
onboarding.currentVersion         // String
onboarding.completedSections      // Set<String>

onboarding.complete()             // Mark as done
onboarding.reset()                // Reset (testing)
onboarding.needsReOnboarding(since: "2.0.0")  // Bool

// Section tracking (for immersive onboarding resume):
onboarding.completeSection("welcome")
onboarding.isSectionCompleted("welcome")  // Bool

// Simple modifier — shows OnboardingFlow on first launch:
ContentView()
    .onboarding(manager: onboarding, pages: [
        OnboardingPageItem(media: .systemIcon(name: "star.fill", color: .yellow),
            title: "Welcome", description: "Get started")
    ])

// Immersive modifier — shows ImmersiveOnboardingFlow on first launch:
ContentView()
    .immersiveOnboarding(manager: onboarding, sections: [
        OnboardingSection(title: "Welcome") {
            TextRevealBlock("Hello!", font: .title)
        }
    ])
```

---

## Immersive Onboarding

Full-screen, progressive onboarding experience with no skip button. Content reveals section-by-section with time-gating, typing effects, haptics, and rich media. Reusable across all apps.

### ImmersiveOnboardingFlow

Main container view. Manages sections, progress bar, continue button, background music.

```swift
public init(
    sections: [OnboardingSection],
    showProgressBar: Bool = true,
    progressBarColor: Color? = nil,
    manager: OnboardingManager? = nil,
    backgroundSound: String? = nil,           // Bundle sound to loop (e.g., "ambient.mp3")
    backgroundSoundVolume: Float = 0.15,
    typingSound: TypingSoundStyle = .hapticOnly, // .none, .hapticOnly, .hapticWithSound, .custom(sound:volume:)
    onComplete: @escaping () -> Void
)
```

```swift
ImmersiveOnboardingFlow(
    sections: [welcomeSection, featuresSection],
    backgroundSound: "ambient.mp3",
    typingSound: .softTick,
    manager: onboardingManager,
    onComplete: { }
)
```

### OnboardingSection

A single section/chapter containing multiple content blocks that reveal sequentially.

```swift
public init(
    id: String = UUID().uuidString,
    title: String? = nil,
    subtitle: String? = nil,
    backgroundColor: Color? = nil,
    accentColor: Color = .accentColor,
    minimumDisplayTime: Duration = .seconds(5),
    continueButtonLabel: String = "Continue",
    celebrateOnComplete: Bool = false,
    @ImmersiveBlockBuilder blocks: () -> [any ContentBlock]
)
```

```swift
OnboardingSection(
    title: "Welcome",
    accentColor: .blue,
    minimumDisplayTime: .seconds(6),
    celebrateOnComplete: true
) {
    ImageRevealBlock(.system("star.fill", .blue), timing: .scaleIn)
    TextRevealBlock("Hello!", font: .title, weight: .bold, timing: .typewriter)
    FeatureHighlightBlock(icon: "heart.fill", iconColor: .pink,
        title: "Feature", description: "Description")
}
```

### RevealTiming

Timing configuration for content block reveal animations.

```swift
public init(
    delay: Duration = .zero,       // Delay after previous block finishes
    duration: Duration = .seconds(0.6),
    style: RevealStyle = .fadeIn
)
```

Presets: `.standard`, `.slow`, `.typewriter`, `.slideUp`, `.scaleIn`

RevealStyle options: `.fadeIn`, `.typewriter(charactersPerSecond:)`, `.wordByWord(interval:)`, `.slideUp`, `.slideFromLeading`, `.slideFromTrailing`, `.scaleIn`

### TextRevealBlock

Text that reveals progressively via typewriter (character-by-character) or word-by-word animation. Automatically pauses at sentence boundaries (400ms at `.` `!` `?`, 150ms at `,`).

```swift
public init(
    id: String = UUID().uuidString,
    _ text: String,
    font: Font = .body,
    weight: Font.Weight? = nil,
    color: Color? = nil,
    alignment: TextAlignment = .center,
    timing: RevealTiming = .typewriter,
    hapticOnReveal: Bool = false        // Subtle haptic per word (word-by-word only)
)
```

```swift
TextRevealBlock("Welcome to our app!", font: .title, weight: .bold,
    timing: .typewriter)

TextRevealBlock("Each word fades in smoothly.", font: .body,
    timing: RevealTiming(style: .wordByWord(interval: .milliseconds(150))),
    hapticOnReveal: true)
```

### ImageRevealBlock

Image that reveals with fade/scale animation. Supports asset images and SF Symbols.

```swift
public init(
    id: String = UUID().uuidString,
    _ source: OnboardingImageSource,    // .asset(String) or .system(String, Color)
    maxHeight: CGFloat = 240,
    cornerRadius: CGFloat? = nil,
    timing: RevealTiming = .scaleIn
)
```

```swift
ImageRevealBlock(.system("star.fill", .blue), timing: .scaleIn)
ImageRevealBlock(.asset("hero-image"), maxHeight: 300)
```

### FeatureHighlightBlock

Icon + title + description card for showcasing app features.

```swift
public init(
    id: String = UUID().uuidString,
    icon: String,                    // SF Symbol name
    iconColor: Color = .accentColor,
    title: String,
    description: String,
    timing: RevealTiming = .slideUp
)
```

```swift
FeatureHighlightBlock(
    icon: "chart.bar.fill", iconColor: .blue,
    title: "Track Progress",
    description: "See your trends at a glance.",
    timing: RevealTiming(delay: .seconds(0.3), style: .slideUp)
)
```

### CardRevealBlock

Generic themed card container that slides into view.

```swift
public init(
    id: String = UUID().uuidString,
    timing: RevealTiming = .slideUp,
    @ViewBuilder content: @escaping () -> Content
)
```

```swift
CardRevealBlock(timing: RevealTiming(style: .slideFromLeading)) {
    HStack { Text("Step 1"); Text("Do this thing") }
}
```

### InteractiveBlock

Pauses onboarding progression until the user completes an interaction.

```swift
public init(
    id: String = UUID().uuidString,
    instruction: String? = nil,
    timing: RevealTiming = .standard,
    @ViewBuilder content: @escaping (Binding<Bool>) -> Content
)
```

```swift
InteractiveBlock(instruction: "Tap to continue") { completed in
    Button("Tap me!") { completed.wrappedValue = true }
}
```

### VideoBlock

Inline video player. Auto-plays when revealed, supports looping. Requires AVKit.

```swift
public init(
    id: String = UUID().uuidString,
    source: OnboardingVideoSource,    // .bundle(name:extension:) or .url(URL)
    aspectRatio: CGFloat = 16.0 / 9.0,
    autoplay: Bool = true,
    loops: Bool = true,
    showControls: Bool = false,
    cornerRadius: CGFloat? = nil,
    timing: RevealTiming = .scaleIn
)
```

```swift
VideoBlock(source: .bundle(name: "tutorial", extension: "mp4"))
VideoBlock(source: .url(URL(string: "https://example.com/video.mp4")!),
    showControls: true, loops: false)
```

### SpacerBlock

Animated spacer or divider between content blocks.

```swift
public init(
    id: String = UUID().uuidString,
    height: CGFloat = 16,
    showDivider: Bool = false,
    timing: RevealTiming = .init(duration: .seconds(0.3), style: .fadeIn)
)
```

```swift
SpacerBlock(height: 12)
SpacerBlock(height: 1, showDivider: true)
```

### CustomBlock

Wrapper for arbitrary SwiftUI content. Receives reveal progress (0...1).

```swift
public init(
    id: String = UUID().uuidString,
    timing: RevealTiming = .standard,
    @ViewBuilder content: @escaping (Double) -> Content
)
```

```swift
CustomBlock { progress in
    MyCustomView().opacity(progress)
}
```

### TypingSoundStyle

Controls haptics and sound during typewriter text reveal. Haptics use Core Haptics (CHHapticEngine) for reliable rapid-fire patterns.

```swift
// Options:
TypingSoundStyle.none                                    // No haptics or sound
TypingSoundStyle.hapticOnly                              // Haptic rhythm only (default)
TypingSoundStyle.hapticWithSound                         // Haptic rhythm + system tick sound
TypingSoundStyle.custom(sound: "typing.mp3", volume: 0.3) // Haptic + custom looping audio
```

---

## Appearance Modifiers

Reusable view modifiers for entrance animations. Usable in onboarding and throughout any app.

### .donkeyAppear()

Animates a view's appearance when it first appears on screen.

```swift
.donkeyAppear(_ style: AppearStyle = .fade, delay: Double = 0, animation: Animation = .smoothSpring)
```

AppearStyle options: `.fade`, `.slideUp(distance:)`, `.slideDown(distance:)`, `.slideLeading(distance:)`, `.slideTrailing(distance:)`, `.scale(from:)`, `.pop(from:)`, `.cardEntrance`, `.blur(radius:)`

```swift
Text("Hello").donkeyAppear(.slideUp())
Image("hero").donkeyAppear(.scale(), delay: 0.3)
CardView().donkeyAppear(.cardEntrance, animation: .bouncySpring)
Text("Pop!").donkeyAppear(.pop(), delay: 0.5, animation: .bouncySpring)
```

### .donkeyStagger()

Cascading entrance animation for items in a list. Each item's delay is based on its index.

```swift
.donkeyStagger(index: Int, style: AppearStyle = .slideUp(), baseDelay: Double = 0.1, interval: Double = 0.08, animation: Animation = .contentSlide)
```

```swift
ForEach(Array(items.enumerated()), id: \.element.id) { i, item in
    ItemRow(item: item)
        .donkeyStagger(index: i, style: .slideUp())
}
```

### Transitions

Custom `AnyTransition` values for SwiftUI transition animations.

```swift
.transition(.slideUp)           // Slide up + fade (insert), fade (remove)
.transition(.scaleWithFade)     // Scale + fade both directions
.transition(.cardEntrance)      // Bottom slide + scale + fade
.transition(.slideFromLeading)  // Leading edge slide + fade
.transition(.slideFromTrailing) // Trailing edge slide + fade
```

---

## Text Renderers (iOS 18+)

Per-glyph text animation effects using Apple's TextRenderer protocol. Falls back to static text on older versions.

### .donkeyWaveText()

Continuous sine-wave ripple animation across each character. Great for titles and celebration moments.

```swift
.donkeyWaveText(isActive: Bool = true, strength: Double = 4, frequency: Double = 0.4, speed: Double = 3.0)
```

```swift
Text("Achievement Unlocked!")
    .font(.title).bold()
    .donkeyWaveText()

Text("Welcome")
    .donkeyWaveText(strength: 6, frequency: 0.3, speed: 2)
```

### .donkeyShimmerText()

Horizontal shimmer/highlight sweep across text. Good for loading states or drawing attention.

```swift
.donkeyShimmerText(isActive: Bool = true, speed: Double = 2.0)
```

```swift
Text("Loading your data...")
    .font(.headline)
    .donkeyShimmerText()
```

### DonkeyTypewriterRenderer

Per-glyph typewriter reveal with fade + slide-up per character. More polished than string truncation.

```swift
DonkeyTypewriterRenderer(progress: Double = 1.0)
```

```swift
Text("This text reveals beautifully")
    .textRenderer(DonkeyTypewriterRenderer(progress: revealProgress))
```

---

## Event Tracking

### DonkeyEventTracker

Batched event tracking with auto-flush. No hardcoded API.

```swift
public init(
    maxQueueSize: Int = 20,
    flushInterval: TimeInterval = 30,
    maxRetainedEvents: Int = 200,
    flushHandler: @escaping @Sendable ([DonkeyEvent]) async throws -> Void
)
```

**DonkeyEvent:**
```swift
DonkeyEvent(event: String, metadata: [String: String], timestamp: String)
```

**Usage:**
```swift
let tracker = DonkeyEventTracker { events in
    let payload = events.map { ["event": $0.event, "metadata": $0.metadata, "timestamp": $0.timestamp] }
    try await api.trackEvents(payload)
}
ContentView().environment(tracker)

@Environment(DonkeyEventTracker.self) var tracker

// Core
tracker.track("custom_event", metadata: ["key": "value"])
await tracker.flush()

// Lifecycle
tracker.appOpened()           // tracks with device info
tracker.appBackgrounded()     // flushes queue

// Sessions
tracker.sessionStarted()      // -> sessionID
tracker.sessionEnded()        // tracks duration

// Convenience
tracker.viewedPage("settings")
tracker.paywallShown(trigger: "feature_gate")
tracker.paywallDismissed()
tracker.purchased(productID: "com.app.yearly")
tracker.notificationPermission(granted: true)
tracker.onboardingStep("welcome")
tracker.onboardingCompleted()
```

---

### DonkeySyncQueue

Persistent sync queue with debounced batching, entity coalescing, exponential backoff retries, and network-aware flush. Pairs with donkeygo's `POST /api/v1/sync/batch` endpoint. Never loses data — queue survives app kills via `SyncQueueStore` persistence protocol.

```swift
public init(
    store: SyncQueueStore,
    debounceInterval: TimeInterval = 30,
    maxWaitInterval: TimeInterval = 120,
    maxBatchSize: Int = 500,
    maxRetryAttempts: Int = 10,
    baseRetryDelay: TimeInterval = 5,
    conflictResolver: SyncConflictResolver? = nil,
    flushHandler: @escaping @Sendable ([SyncQueueItem], String) async throws -> SyncFlushResult
)
```

**SyncQueueItem:**
```swift
SyncQueueItem.upsert(entityType: "habit", entityID: "abc", version: 1, fields: ["name": AnySendable("Run")])
SyncQueueItem.delete(entityType: "habit", entityID: "abc")
```

**SyncFlushResult:**
```swift
SyncFlushResult(succeeded: [SyncItemResult], conflicts: [SyncConflict], failed: [SyncItemFailure])
SyncItemResult(clientID: String, serverID: String, version: Int)
SyncConflict(clientID: String, serverVersion: Int)
SyncItemFailure(clientID: String, error: String)
```

**Protocols:**
```swift
protocol SyncQueueStore: Sendable {
    func save(_ item: SyncQueueItem) async throws
    func remove(entityType: String, entityID: String) async throws
    func loadAll() async throws -> [SyncQueueItem]
    func removeAll() async throws
}

protocol SyncConflictResolver: Sendable {
    func resolve(item: SyncQueueItem, serverVersion: Int) async -> SyncQueueItem?
}
```

**Usage:**
```swift
let syncQueue = DonkeySyncQueue(store: mySQLiteStore) { items, idempotencyKey in
    try await api.syncBatch(items: items, idempotencyKey: idempotencyKey)
}

// Enqueue mutations (coalesces by entity)
syncQueue.enqueue(.upsert(entityType: "habit", entityID: id, version: 1, fields: ["name": AnySendable("Run")]))
syncQueue.enqueue(.delete(entityType: "habit", entityID: id))

// Manual flush (pull-to-refresh, etc.)
await syncQueue.flush()

// Clear on sign out
await syncQueue.clear()

// Observable state for UI
syncQueue.state      // SyncState (.idle, .syncing, .upToDate, .error)
syncQueue.pendingCount  // Int
```

**Key behaviors:**
- Debounce: 30s after last enqueue, max 2min before forced flush
- Coalescing: multiple edits to same entity = one sync item
- Create + delete in same window = both dropped (cancel out)
- Auto-flush on: app background, app foreground, network restored
- Retry: exponential backoff (5s → 10s → 20s → ... capped 5min), max 10 attempts
- Idempotency key per flush — safe retries via server's `X-Idempotency-Key`
- Integrates with `NetworkMonitor` and `SyncState` (used by `SyncStatusView`)

---

## Shader Effects (iOS 17+)

Metal GPU shader effects as SwiftUI view modifiers. Runs on the GPU at 60/120fps with negligible CPU cost.

### .donkeyShimmer()

Diagonal shine sweep using HSL lightness boost. Perfect for premium buttons, badges, CTAs, and paywalls.

```swift
.donkeyShimmer(isActive: Bool = true, duration: Double = 2.0, gradientWidth: Double = 0.3, maxLightness: Double = 0.5)
```

```swift
Text("PRO").donkeyShimmer()
Button("Upgrade") { }.donkeyShimmer(maxLightness: 0.8, duration: 3)
ThemedButton("Subscribe", role: .primary) { }.donkeyShimmer()
```

---

## Extensions

### Color

```swift
Color(hex: "FF5733")          // Init from hex string
color.toHex() -> String?      // Convert to hex
color.buttonText(darkMode:)   // Contrast text color
color.buttonBackground()      // Lightened background
```

### UIColor / NSColor

```swift
uiColor.lighter(componentDelta: 0.1) -> UIColor
uiColor.darker(componentDelta: 0.1) -> UIColor
```

### Date

```swift
date.startOfDay / date.endOfDay
date.tomorrow / date.yesterday
date.startOfMonth / date.endOfMonth
date.month / date.day / date.year
date.monthString          // "March" or "March 2025"
date.dateString            // "March, 18, 2026"
date.timeString            // "09:30 AM" or "09:30"
date.dayOfWeekString       // "Tuesday"
date.dayOfWeek             // 3 (weekday component)
date.timestamp() -> Int64  // milliseconds since epoch
date.distanceInText(date:) // "Today", "Yesterday", "2 weeks ago"
date.getDate(dayDifference:)
date.addMinutes(minuteDifference:)
date.inRange(start:end:)
```

### Double

```swift
value.balanceString              // "$1,234.56"
value.balanceStringWithSign      // "+$1,234.56"
value.balanceColor               // .green or .pink
value.percentageLabel            // "45.50%"
```

### Locale

```swift
Locale.is24Hour -> Bool
```

### Bundle

```swift
Bundle.main.iconFileName -> String?  // App icon file name
```

### AppIcon (View)

Displays the app icon from the bundle.

```swift
AppIcon()
```

### Animation

```swift
Animation.ripple(index: Int)  // Staggered spring animation

// Presets (iOS 17+):
Animation.quickSpring        // 0.3s, bounce 0.2 — UI feedback
Animation.smoothSpring       // 0.5s, bounce 0.1 — page transitions
Animation.bouncySpring       // 0.6s, bounce 0.35 — playful interactions
Animation.subtle             // 0.2s easeInOut — small changes
Animation.snappy             // 0.15s easeOut — toggles/switches
Animation.gentleReveal       // 0.8s easeInOut — onboarding content
Animation.contentSlide       // 0.5s spring, bounce 0.15 — card slides
```

### Optional<NSSet>

```swift
optionalNSSet.array(of: MyType.self) -> [MyType]
```

### UNUserNotificationCenter

```swift
center.createNotification(id:title:content:date:badge:)
center.createDailyNotification(id:title:content:hour:minute:)
```

### NSManagedObject

```swift
managedObject.addObject(value:forKey:)
managedObject.removeObject(value:forKey:)
```

### StatefulPreviewWrapper

Wrapper for using `@State` in SwiftUI previews.

```swift
StatefulPreviewWrapper(false) { isOn in
    Toggle("Test", isOn: isOn)
}
```

---

## Watch Connectivity

Reusable WatchConnectivity session managers for iPhone ↔ Apple Watch communication.

### DonkeyPhoneSession (iOS)

iPhone-side session manager. Handles WCSession lifecycle, throttled context pushes, and message routing via delegate.

```swift
public protocol DonkeyPhoneSessionDelegate: AnyObject {
    func phoneSessionBuildContext() -> [String: Any]
    func phoneSessionDidReceiveMessage(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)?)
}

public final class DonkeyPhoneSession: NSObject, WCSessionDelegate {
    public static let shared: DonkeyPhoneSession
    public weak var delegate: DonkeyPhoneSessionDelegate?
    public var throttleInterval: TimeInterval  // default 1s
    public var isPaired: Bool
    public var isReachable: Bool
    public func syncToWatch()
}
```

Usage (iPhone app):

```swift
class MyWatchSync: DonkeyPhoneSessionDelegate {
    init() {
        DonkeyPhoneSession.shared.delegate = self
    }

    func phoneSessionBuildContext() -> [String: Any] {
        ["token": token, "score": currentScore, "level": level]
    }

    func phoneSessionDidReceiveMessage(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)?) {
        if message["request"] as? String == "sync" {
            replyHandler?(phoneSessionBuildContext())
        } else if message["action"] as? String == "log" {
            handleWatchLog(message)
        }
    }
}
```

### DonkeyWatchSession (watchOS)

Watch-side session manager. Tracks reachability, deduplicates by timestamp, and routes data to delegate.

```swift
public protocol DonkeyWatchSessionDelegate: AnyObject {
    func watchSessionDidReceiveData(_ data: [String: Any])
}

public final class DonkeyWatchSession: NSObject, ObservableObject, WCSessionDelegate {
    public static let shared: DonkeyWatchSession
    @Published public var isReachable: Bool
    public weak var delegate: DonkeyWatchSessionDelegate?
    @discardableResult public func sendMessage(_ message: [String: Any], errorHandler: ((Error) -> Void)?) -> Bool
    public func sendMessage(_ message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void, errorHandler: ((Error) -> Void)?) -> Bool
    public func requestSync(message: [String: Any])
}
```

Usage (Watch app):

```swift
class MyWatchStore: DonkeyWatchSessionDelegate {
    init() {
        DonkeyWatchSession.shared.delegate = self
    }

    func watchSessionDidReceiveData(_ data: [String: Any]) {
        score = data["score"] as? Int ?? 0
        level = data["level"] as? Int ?? 1
    }

    func logAction() {
        DonkeyWatchSession.shared.sendMessage(["action": "log", "value": 42])
    }
}
```

---

## DonkeyUIDefaults

Legacy static colors (prefer theme colors instead).

```swift
DonkeyUIDefaults.secondaryBackground  // Color
DonkeyUIDefaults.systemBackground     // Color
```

---

## Chat

### DonkeyChatManager

Observable chat manager with WebSocket real-time delivery, auto-reconnect with exponential backoff, typing indicators, and image upload support. No hardcoded endpoints — apps provide all networking via callbacks.

```swift
let chatConfig = DonkeyChatConfig(
    websocketURL: { token in URL(string: "wss://api.example.com/chat/ws?token=\(token)") },
    getSessionToken: { UserDefaults.standard.string(forKey: "sessionToken") },
    fetchMessages: { limit, offset in
        let page = try await api.getChatHistory(limit: limit, offset: offset)
        return DonkeyChatPage(messages: page.messages.map { ... }, hasMore: page.hasMore)
    },
    sendMessage: { text, type in
        let result = try await api.sendChatMessage(text, messageType: type)
        return DonkeyChatSendResult(id: result.id, createdAt: result.createdAt)
    },
    uploadImage: { data in try await api.uploadChatImage(data) },
    onEvent: { event in EventTracker.shared.track("chat_\(event)") }
)
let chatManager = DonkeyChatManager(config: chatConfig)
```

```swift
// Public state
chatManager.messages          // [DonkeyChatMessage]
chatManager.isLoading         // Bool
chatManager.isSending         // Bool
chatManager.isConnected       // Bool (WebSocket)
chatManager.isRemoteTyping    // Bool
chatManager.hasMore           // Bool (pagination)
chatManager.isUploadingImage  // Bool
chatManager.uploadError       // String?
chatManager.supportsImages    // Bool

// Public methods
await chatManager.start()                    // Load messages + connect WS
chatManager.stop()                           // Disconnect WS
await chatManager.loadMessages()             // Reload from server
await chatManager.loadMore()                 // Load older messages
let sent = await chatManager.sendMessage(text)  // Send text, returns Bool
let sent = await chatManager.sendImage(image)   // Send UIImage, returns Bool
chatManager.sendTyping(userId: id)           // Send typing indicator
```

### DonkeyChatView

Drop-in support chat view with themed message bubbles, image support, typing indicators, pagination, and relative timestamps. Wraps `DonkeyChatManager`.

```swift
DonkeyChatView(
    manager: chatManager,
    userId: auth.user?.id ?? "",
    title: "Chat with Support",
    emptyTitle: "No messages yet",
    emptySubtitle: "We typically reply within a few hours"
)
```

### DonkeyChatMessage

Message model used by DonkeyChatManager and DonkeyChatView.

```swift
public struct DonkeyChatMessage: Identifiable, Equatable, Sendable {
    public let id: Int
    public let userId: String
    public let sender: String        // "user" or "admin"
    public let message: String
    public let messageType: String   // "text" or "image"
    public let readAt: String?
    public let createdAt: String
    public var isUser: Bool
    public var isImage: Bool
}
```

### DonkeyChatConfig

Configuration for DonkeyChatManager. All networking is callback-based — no hardcoded endpoints.

```swift
public struct DonkeyChatConfig {
    let websocketURL: (String) -> URL?              // Build WS URL from session token
    let getSessionToken: () -> String?              // Return current session token
    let fetchMessages: (Int, Int) async throws -> DonkeyChatPage  // (limit, offset)
    let sendMessage: (String, String) async throws -> DonkeyChatSendResult  // (text, messageType)
    let uploadImage: ((Data) async throws -> String)?  // Upload image data, return URL
    let onEvent: ((DonkeyChatConfig.ChatEvent) -> Void)?  // Analytics
    let adminDisplayName: String                    // Default: "Developer"
    let imageCompressionQuality: CGFloat            // Default: 0.7
    let maxReconnectDelay: TimeInterval             // Default: 30
}
```

### DonkeyChatPage

Response from fetchMessages callback.

```swift
public struct DonkeyChatPage {
    public let messages: [DonkeyChatMessage]
    public let hasMore: Bool
}
```

### DonkeyChatSendResult

Response from sendMessage callback.

```swift
public struct DonkeyChatSendResult {
    public let id: Int?
    public let createdAt: String?
}
```

---

## watchOS UI

> Platform: watchOS 10+ only (`#if os(watchOS)`)

### DonkeyTheme.watchAdjusted()

Returns a theme copy with tighter spacing, bolder weights, and smaller radii suited for watchOS.

```swift
public extension DonkeyTheme {
    func watchAdjusted() -> DonkeyTheme
}
```

```swift
ContentView()
    .donkeyTheme(DonkeyTheme().watchAdjusted())
```

### WatchListRow

Watch-optimized list row with 44pt+ touch targets, simplified accessories.

```swift
public init(
    icon: String? = nil,
    iconColor: Color = .accentColor,
    title: String,
    subtitle: String? = nil,
    accessory: WatchListRowAccessory = .none,
    action: (() -> Void)? = nil
)
```

Accessories: `.chevron`, `.info(String)`, `.none`

```swift
WatchListRow(
    icon: "bell.fill",
    iconColor: .red,
    title: "Notifications",
    accessory: .chevron,
    action: { }
)
```

### WatchCardView

Compact card for watchOS: reduced padding, no shadow, edge-to-edge.

```swift
public init(@ViewBuilder content: () -> Content)
```

```swift
WatchCardView {
    VStack(alignment: .leading) {
        Text("Steps").font(.caption)
        Text("8,432").font(.title2).bold()
    }
}
```

### WatchEmptyState

Compact empty state: 32pt icon, headline title, optional button.

```swift
public init(
    systemIcon: String,
    title: String,
    buttonLabel: String? = nil,
    buttonAction: (() -> Void)? = nil
)
```

```swift
WatchEmptyState(
    systemIcon: "tray",
    title: "No Items",
    buttonLabel: "Add",
    buttonAction: { }
)
```

### Digital Crown Modifiers

Bind Digital Crown rotation with haptic feedback.

```swift
// Continuous rotation
.donkeyCrownRotation(value: Binding<Double>, range: ClosedRange<Double>, sensitivity: DigitalCrownRotationalSensitivity = .medium)

// Discrete stepping
.donkeyCrownStepper(value: Binding<Double>, in: ClosedRange<Double>, step: Double = 1.0)
```

```swift
Text("Volume: \(Int(volume))")
    .donkeyCrownRotation(value: $volume, range: 0...100)

Text("Rating: \(Int(rating))")
    .donkeyCrownStepper(value: $rating, in: 1...5, step: 1)
```

### WatchNotificationView

Themed container for watchOS notification views.

```swift
public init(
    icon: String,
    iconColor: Color = .accentColor,
    title: String,
    body: String
)
```

```swift
WatchNotificationView(
    icon: "bell.fill",
    iconColor: .orange,
    title: "Reminder",
    body: "Don't forget your workout."
)
```

### WatchConfirmation

Full-screen confirmation overlay with large tap targets.

```swift
public init(
    isPresented: Binding<Bool>,
    message: String,
    confirmLabel: String = "Confirm",
    cancelLabel: String = "Cancel",
    isDestructive: Bool = false,
    onConfirm: @escaping () -> Void
)
```

```swift
// As a modifier:
.watchConfirmation(
    isPresented: $showConfirm,
    message: "Delete this item?",
    confirmLabel: "Delete",
    isDestructive: true,
    onConfirm: { deleteItem() }
)
```

---

## macOS

> Items marked `#if !os(watchOS)` work on both macOS and iOS. Items marked `#if os(macOS)` are macOS-only.

### DonkeyShortcutModifier

Applies a keyboard shortcut. Available on macOS and iOS (hardware keyboard).

```swift
.donkeyShortcut(_ key: KeyEquivalent, modifiers: EventModifiers = .command)
```

```swift
Button("Save") { save() }
    .donkeyShortcut("s")
```

### DonkeyShortcutGroup

Renders a styled list of keyboard shortcuts for a help overlay.

```swift
public init(title: String = "Keyboard Shortcuts", shortcuts: [DonkeyShortcutDescriptor])
```

```swift
DonkeyShortcutGroup(shortcuts: [
    DonkeyShortcutDescriptor(title: "New Item", key: "N"),
    DonkeyShortcutDescriptor(title: "Save", key: "S"),
])
```

### DonkeyHoverModifier

Animated hover effect for macOS pointer and iPad cursor interactions.

```swift
.donkeyHover(scale: CGFloat = 1.02, opacity: CGFloat = 0.9, highlightColor: Color? = nil)
```

```swift
Text("Hover me")
    .padding()
    .donkeyHover(highlightColor: .blue.opacity(0.1))
```

### DonkeySidebarNavigation

Themed `NavigationSplitView` wrapper with sidebar and detail panes.

```swift
public init(
    columnVisibility: Binding<NavigationSplitViewVisibility> = .constant(.automatic),
    @ViewBuilder sidebar: () -> Sidebar,
    @ViewBuilder detail: () -> Detail
)
```

```swift
DonkeySidebarNavigation {
    List(selection: $selected) { ... }
} detail: {
    DetailView(item: selected)
}
```

### DonkeyToolbarStyle

Toolbar modifier with platform-correct leading/trailing placements.

```swift
.donkeyToolbar(leading: () -> some View, trailing: () -> some View)
```

```swift
ContentView()
    .donkeyToolbar {
        Button("Back") { }
    } trailing: {
        Button("Save") { }
    }
```

### DonkeySettingsTab

macOS-only. Themed settings tab with Form styling. `#if os(macOS)`

```swift
public init(_ label: String, systemImage: String, @ViewBuilder content: () -> Content)
```

```swift
TabView {
    DonkeySettingsTab("General", systemImage: "gear") {
        Toggle("Notifications", isOn: $notifs)
    }
}
```

### DonkeyMenuBarSection / DonkeyMenuBarRow

macOS-only. Components for `MenuBarExtra` content. `#if os(macOS)`

```swift
DonkeyMenuBarSection(title: "Actions") {
    DonkeyMenuBarRow(icon: "plus", title: "New Window", shortcut: "⌘N") { }
    DonkeyMenuBarRow(icon: "gear", title: "Preferences") { }
}
```

### DonkeyPasteboard / .donkeyCopyable()

Cross-platform clipboard helper.

```swift
DonkeyPasteboard.copy("Hello")

Text("Copy me")
    .donkeyCopyable("Copy me")  // adds "Copy" context menu
```

### DonkeyWindowHelper

macOS-only. Window configuration via NSViewRepresentable. `#if os(macOS)`

```swift
.donkeyWindowStyle(titleBarHidden: Bool = false, minSize: CGSize? = nil)
```

```swift
ContentView()
    .donkeyWindowStyle(titleBarHidden: true, minSize: CGSize(width: 300, height: 200))
```

---

## Adaptive / iPad

> Size-class-aware components for iPad and macOS. Most use `#if !os(watchOS)`.

### AdaptiveLayout

Renders compact or regular content based on horizontal size class. Always compact on watchOS. Works on all platforms.

```swift
public init(
    @ViewBuilder compact: @escaping () -> Compact,
    @ViewBuilder regular: @escaping () -> Regular
)
```

```swift
AdaptiveLayout {
    VStack { items }
} regular: {
    HStack { items }
}
```

### AdaptiveColumns

Responsive grid with automatic column count based on available width.

```swift
public init(minWidth: CGFloat = 300, spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content)
```

```swift
AdaptiveColumns(minWidth: 200) {
    ForEach(items) { item in
        CardView(item: item)
    }
}
```

### SplitDetailView

Two-column sidebar + detail with selection state and empty placeholder.

```swift
public init(
    selection: Binding<Item?>,
    @ViewBuilder sidebar: @escaping () -> Sidebar,
    @ViewBuilder detail: @escaping (Item) -> Detail
)
```

```swift
SplitDetailView(selection: $selected) {
    List(items, selection: $selected) { item in
        Text(item.name).tag(item)
    }
} detail: { item in
    ItemDetailView(item: item)
}
```

### DonkeyPointerStyle

iPadOS pointer hover effect. `#if os(iOS)`

```swift
.donkeyPointerStyle(_ effect: DonkeyPointerEffect = .automatic)
```

Effects: `.lift`, `.highlight`, `.automatic`

```swift
Button("Tap") { }
    .donkeyPointerStyle(.lift)
```

### AdaptiveSheet

Sheet on compact, popover on regular.

```swift
.donkeyAdaptiveSheet(isPresented: Binding<Bool>, arrowEdge: Edge = .bottom, content: () -> Content)
```

```swift
Button("Show") { showSheet = true }
    .donkeyAdaptiveSheet(isPresented: $showSheet) {
        SettingsView()
    }
```

### DonkeyDragDrop

Simplified drag-and-drop modifiers for `Transferable` types.

```swift
.donkeyDraggable(_ data: some Transferable)
.donkeyDropTarget(for: T.Type, action: ([T]) -> Bool)
```

```swift
Text(item.name)
    .donkeyDraggable(item.name)

DropZone()
    .donkeyDropTarget(for: String.self) { strings in
        handleDrop(strings); return true
    }
```

### DonkeyMultiWindowSupport

Provides access to `openWindow` environment action.

```swift
public struct DonkeyMultiWindowSupport: View {
    public init(onReady: @escaping (OpenWindowAction) -> Void)
}

.donkeyOpenWindow(perform: @escaping @Sendable (OpenWindowAction) -> Void)
```

### AdaptiveNavigationTitle

Navigation title with per-size-class display modes. `#if os(iOS)`

```swift
.donkeyNavigationTitle(_ title: String, compactMode: NavigationBarItem.TitleDisplayMode = .large, regularMode: NavigationBarItem.TitleDisplayMode = .inline)
```

```swift
ContentView()
    .donkeyNavigationTitle("Dashboard", compactMode: .large, regularMode: .inline)
```

---

## Widgets (WidgetKit)

> Items marked `#if canImport(WidgetKit)` require a widget extension target. `DonkeyDeepLink` is pure Foundation.

### DonkeyWidgetTheme

Static theme for widgets (widgets can't use `@Environment`).

```swift
public init(from theme: DonkeyTheme = DonkeyTheme())
public static let `default`: DonkeyWidgetTheme
```

```swift
let theme = DonkeyWidgetTheme.default
// or
let theme = DonkeyWidgetTheme(from: myTheme)
```

### .donkeyContainerBackground()

Applies widget container background.

```swift
.donkeyContainerBackground(_ color: Color)
```

### DonkeySmallWidget / DonkeyMediumWidget / DonkeyLargeWidget

Pre-built widget layouts per family with themed padding and container background.

```swift
DonkeySmallWidget(theme: .default) {
    Image(systemName: "star.fill")
    Text("Score")
    Text("42").font(.largeTitle).bold()
}

DonkeyMediumWidget {
    VStack { Text("Left") }
    Spacer()
    VStack { Text("Right") }
}

DonkeyLargeWidget {
    // header
    Text("Today").font(.headline)
} content: {
    // content
    ForEach(items) { Text($0.name) }
}
```

### DonkeyAccessoryCircular / DonkeyAccessoryRectangular / DonkeyAccessoryInline

Lock screen / watch complication layouts with `widgetAccentable()`.

```swift
DonkeyAccessoryCircular {
    Image(systemName: "heart.fill")
}

DonkeyAccessoryRectangular {
    Text("Steps").font(.caption)
    Text("8,432").font(.headline)
    Text("Today").font(.caption2)
}

DonkeyAccessoryInline("8,432 steps") {
    Image(systemName: "figure.walk")
}
```

### DonkeyDeepLink

Type-safe URL builder for widget tap targets. Pure Foundation — no WidgetKit import needed.

```swift
public protocol DonkeyDeepLinkable {
    var scheme: String { get }  // default "donkey"
    var host: String { get }
    var path: String { get }
    var queryItems: [URLQueryItem] { get }  // default []
    var url: URL { get }  // computed
}

public enum DonkeyDeepLink {
    public static func parse<T: DonkeyDeepLinkable>(_ url: URL, as type: T.Type) -> T?
        where T: RawRepresentable, T.RawValue == String
}
```

```swift
enum AppLink: String, DonkeyDeepLinkable {
    case home, settings, profile

    var host: String { rawValue }
    var path: String { "/" }
}

// Build URL:
let url = AppLink.home.url  // donkey://home/

// Parse URL:
if let link = DonkeyDeepLink.parse(url, as: AppLink.self) { ... }
```

### DonkeyTimelineHelper

Static helpers for building widget timelines.

```swift
// Single entry refreshing after N minutes
DonkeyTimelineHelper.singleEntry(entry, refreshAfter: 30)

// Multiple entries at regular intervals
DonkeyTimelineHelper.entries(count: 24, interval: 3600) { date in
    MyEntry(date: date, value: fetchValue())
}
```

### DonkeyWidgetPreviewContainer

Preview container that simulates widget family sizes.

```swift
public init(family: WidgetFamily, @ViewBuilder content: @escaping () -> Content)
```

```swift
#Preview {
    DonkeyWidgetPreviewContainer(family: .systemSmall) {
        DonkeySmallWidget { Text("Preview") }
    }
}
```
