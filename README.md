# DonkeyUI

A reusable SwiftUI component library for iOS and macOS apps. Production-tested across multiple App Store apps.

## Requirements

- iOS 16+ / macOS 14+
- Swift 5.9+
- Xcode 15+

## Installation

**Swift Package Manager** (recommended):

In Xcode: File → Add Package Dependencies → paste:
```
https://github.com/pacosw1/DonkeyUI.git
```

Or add to `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/pacosw1/DonkeyUI.git", from: "1.0.0")
]
```

## Components

### Buttons
- **`ButtonView`** — Versatile button with styles: `.filled`, `.bordered`, `.text`, `.card`. Supports loading state, icons, and full-width layout.
- **`CheckButtonView`** — Animated checkbox with 5 size variants (`.tiny` through `.large`).
- **`CloseButton`** — Standard close/dismiss button.
- **`FloatingActionButton`** — FAB modifier with haptic feedback.

### Progress & Charts
- **`CircularProgressView`** — Circular progress ring with completion checkmark animation.
- **`ProgressBarView`** — Linear progress bar with spring animation.
- **`PieChartView`** — Interactive pie chart with touch-to-select slices.
- **`ProgressStepperView`** — Multi-step progress indicator.
- **`StackedChartView`** — Stacked bar chart.

### Tags
- **`TagView`** — Color-coded tag with optional delete button.
- **`ScrollTagSelector`** — Horizontal scrolling tag picker with protocol-based data.

### Input
- **`NumberPadInput`** — Custom numeric keypad with configurable layout.
- **`MoneyInputView`** — Currency input field.
- **`ColorPickerView`** — Grid-based color selector.

### Paywall & Monetization
- **`PaywallView`** — Full paywall screen powered by RevenueCat. Includes plan selection, feature highlights, and purchase flow.
- **`PaywallModifier`** — Present paywall as sheet or fullscreen cover.
- **`TipJarView`** — Tip jar with StoreKit 2 integration.

> **Important:** Your app must call `Purchases.configure(withAPIKey:)` before presenting `PaywallView`. The library does not configure RevenueCat itself.

### Settings
- **`SettingToggleView`** — Toggle row with icon and optional caption.
- **`UseBiometricsToggle`** — Face ID / Touch ID toggle with auto-detection.
- **`DailyReminderView`** — Time picker with local notification scheduling.
- **`FeedbackView`** — User feedback form (positive, negative, bug, feature).
- **`LeaveReviewView`** — App Store review prompt link.
- **`CloudSyncView`** — CloudKit sync status display.

### Views
- **`BiometricLockView`** — Lock screen with Face ID / Touch ID authentication.
- **`InfiniteCarouselView`** — Carousel with next/prev navigation.
- **`OnboardingPanelView`** — Onboarding page with image, title, and description.
- **`WhatsNewView`** — What's new changelog display.
- **`PagerView`** — Swipeable page view.
- **`HomeScrollView`** — Scroll view with pull-to-search detection.
- **`ExpandView`** — Expandable/collapsible section.

### Modifiers
- **`.card()`** — Card styling with padding and corner radius.
- **`.bgOverlay()`** — Background with border and corner radius.
- **`.bordered()`** — Rounded rectangle background.
- **`.wiggling()`** — Continuous wiggle animation (for edit mode).
- **`.errorToast()`** — Toast-based error display.
- **`.biometricLock()`** — Biometric lock screen overlay.
- **`.floatingActionButton()`** — FAB overlay.

### Extensions
- **`Color`** — Hex parsing (`Color(hex:)`), `toHex()`, `lighter()`, `darker()`, `buttonText()`.
- **`Date`** — `startOfDay`, `endOfDay`, `tomorrow`, `yesterday`, `distanceInText()`, formatting helpers.
- **`Double/Int`** — Currency formatting (`balanceString`), percentage labels.

### Diagnostics
- **`DonkeyDiagnosticsReporter`** — Native diagnostics client for handled errors, probable previous-run crash signals, slow operations, request failures, and breadcrumb context. Sends app version, build, language, device model, OS version, session ID, installation ID, and persisted breadcrumbs to your backend.

## Usage

```swift
import DonkeyUI

// Button with loading state
ButtonView(
    label: "Subscribe",
    icon: "star.fill",
    color: .blue,
    buttonType: .filled,
    fullWidth: true,
    isLoading: isProcessing
) {
    subscribe()
}

// Circular progress
CircularProgressView(color: .green, progress: 0.75, size: 40)

// Tag
TagView(id: UUID(), title: "Swift", color: .orange)

// Color picker
ColorPickerView(selected: $selectedColor)

// Paywall (RevenueCat must be configured first)
.fullScreenCover(isPresented: $showPaywall) {
    PaywallView(
        views: featureViews,
        successAction: { /* unlock */ },
        onOpen: { /* track */ },
        errorAction: { error, cancelled in /* handle */ },
        proEntitlementId: "Premium",
        isSheet: true,
        privacyUrl: "https://example.com/privacy"
    )
}
```

## Dependencies

- [RevenueCat](https://github.com/RevenueCat/purchases-ios) — In-app purchase management
- [PopupView](https://github.com/exyte/PopupView) — Toast notifications (iOS only)

## License

MIT
