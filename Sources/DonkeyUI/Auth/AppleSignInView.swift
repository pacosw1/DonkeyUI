//
//  AppleSignInView.swift
//  Drop-in Apple Sign In screen. Themed, configurable features list.
//
//  Usage:
//  AppleSignInView(
//      auth: authManager,
//      appName: "Waterful",
//      appIcon: "drop.fill",
//      features: ["Sync across devices", "Smart reminders", "Track progress"],
//      privacyURL: URL(string: "https://example.com/privacy"),
//      termsURL: URL(string: "https://example.com/terms")
//  )
//

import SwiftUI
import AuthenticationServices

// MARK: - AppleSignInView

public struct AppleSignInView: View {
    let auth: DonkeyAuthManager
    let appName: String
    let appIcon: String
    let features: [String]
    let privacyURL: URL?
    let termsURL: URL?
    let onSkip: (() -> Void)?

    @Environment(\.donkeyTheme) var theme
    @Environment(\.colorScheme) var colorScheme
    @State private var showError = false

    public init(
        auth: DonkeyAuthManager,
        appName: String,
        appIcon: String = "app.fill",
        features: [String] = [],
        privacyURL: URL? = nil,
        termsURL: URL? = nil,
        onSkip: (() -> Void)? = nil
    ) {
        self.auth = auth
        self.appName = appName
        self.appIcon = appIcon
        self.features = features
        self.privacyURL = privacyURL
        self.termsURL = termsURL
        self.onSkip = onSkip
    }

    public var body: some View {
        VStack(spacing: theme.spacing.xxl) {
            Spacer()

            // App icon + name
            VStack(spacing: theme.spacing.md) {
                Image(systemName: appIcon)
                    .font(.system(size: 64))
                    .foregroundStyle(theme.colors.accent)

                Text(appName)
                    .font(theme.typography.largeTitle)
                    .fontWeight(theme.typography.heavyWeight)
                    .foregroundStyle(theme.colors.onBackground)
            }

            // Feature highlights
            if !features.isEmpty {
                VStack(alignment: .leading, spacing: theme.spacing.lg) {
                    ForEach(features, id: \.self) { feature in
                        HStack(spacing: theme.spacing.md) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(theme.colors.accent)
                                .frame(width: 24)
                            Text(feature)
                                .font(theme.typography.subheadline)
                                .foregroundStyle(theme.colors.onBackground)
                        }
                    }
                }
                .padding(.horizontal, theme.spacing.xxl)
            }

            Spacer()

            // Sign in button
            VStack(spacing: theme.spacing.md) {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    auth.handleAppleSignIn(result)
                }
                .disabled(auth.isLoading)
                .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
                .frame(height: 50)
                .clipShape(RoundedRectangle(cornerRadius: theme.shape.radiusMedium))
                .padding(.horizontal, theme.spacing.xxl)

                if auth.isLoading {
                    ProgressView("Signing in...")
                        .font(theme.typography.caption)
                        .padding(.top, theme.spacing.xs)
                }

                // Skip button
                if let onSkip {
                    Button("Skip for now") {
                        onSkip()
                    }
                    .font(theme.typography.footnote)
                    .foregroundStyle(theme.colors.secondary)
                }
            }

            // Legal
            legalFooter
                .padding(.bottom, theme.spacing.lg)
        }
        .background(theme.colors.background.ignoresSafeArea())
        .alert("Sign In Failed", isPresented: $showError) {
            Button("OK") { auth.clearError() }
        } message: {
            Text(auth.errorMessage ?? "Unknown error")
        }
        .onChange(of: auth.errorMessage) {
            showError = auth.errorMessage != nil
        }
    }

    // MARK: - Legal Footer

    @ViewBuilder
    private var legalFooter: some View {
        if privacyURL != nil || termsURL != nil {
            VStack(spacing: theme.spacing.xs) {
                Text("By continuing, you agree to our")
                    .font(theme.typography.caption2)
                    .foregroundStyle(theme.colors.secondary)

                HStack(spacing: theme.spacing.xs) {
                    if let termsURL {
                        Link("Terms of Service", destination: termsURL)
                            .font(theme.typography.caption2)
                    }
                    if privacyURL != nil && termsURL != nil {
                        Text("and")
                            .font(theme.typography.caption2)
                            .foregroundStyle(theme.colors.secondary)
                    }
                    if let privacyURL {
                        Link("Privacy Policy", destination: privacyURL)
                            .font(theme.typography.caption2)
                    }
                }
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, theme.spacing.xxl)
        }
    }
}

// MARK: - Modifier

public struct RequireAuthModifier: ViewModifier {
    let auth: DonkeyAuthManager
    let appName: String
    let appIcon: String
    let features: [String]
    let privacyURL: URL?
    let termsURL: URL?

    public func body(content: Content) -> some View {
        if auth.isAuthenticated {
            content
        } else {
            AppleSignInView(
                auth: auth,
                appName: appName,
                appIcon: appIcon,
                features: features,
                privacyURL: privacyURL,
                termsURL: termsURL
            )
        }
    }
}

public extension View {
    /// Shows Apple Sign In screen when not authenticated, content when authenticated.
    func requireAuth(
        auth: DonkeyAuthManager,
        appName: String,
        appIcon: String = "app.fill",
        features: [String] = [],
        privacyURL: URL? = nil,
        termsURL: URL? = nil
    ) -> some View {
        modifier(RequireAuthModifier(
            auth: auth,
            appName: appName,
            appIcon: appIcon,
            features: features,
            privacyURL: privacyURL,
            termsURL: termsURL
        ))
    }
}
