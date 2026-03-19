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

## DonkeyUIDefaults

Legacy static colors (prefer theme colors instead).

```swift
DonkeyUIDefaults.secondaryBackground  // Color
DonkeyUIDefaults.systemBackground     // Color
```
