# DonkeyUI

SwiftUI component library for iOS 17+ / macOS 14+ / watchOS 10+. Distributed via Swift Package Manager.

## Install

```swift
// Package.swift
.package(url: "https://github.com/pacosw1/DonkeyUI.git", branch: "main")
```

## After modifying or adding components

When you add, remove, or modify any public type, view, modifier, helper, or protocol:

1. **Update `COMPONENTS.md`** — Add/update the entry following the existing format (### heading, description, init signature, usage example)
2. **Re-index MCP** — Run `cd mcp && node indexer.mjs` to rebuild the SQLite FTS5 search index
3. **Verify build** — Run `swift build` to confirm compilation

All three steps are required. The MCP index is how LLMs discover components — if you skip step 2, the new component won't be findable.

## Project structure

- `Sources/DonkeyUI/` — All source code
  - `Helpers/` — Non-UI utilities (DonkeySyncQueue, DonkeyEventTracker, NetworkMonitor, Debouncer, etc.)
  - `Components/` — Themed UI components (SyncStatusView, AsyncCachedImage, etc.)
  - `Views/` — View implementations (BiometricLock, Onboarding, Pickers, etc.)
  - `Modifiers/` — SwiftUI view modifiers
  - `Extensions/` — Swift type extensions
  - `Effects/` — Shader effects and text renderers
  - `Theme/` — Semantic theming system
  - `Auth/` — DonkeyAuthManager (Apple Sign In)
  - `Store/` — DonkeyStoreManager (StoreKit 2)
  - `Watch/` — WatchConnectivity managers (DonkeyPhoneSession, DonkeyWatchSession)
  - `ImmersiveOnboarding/` — Full-screen onboarding flows
  - `AmbientSound/` — Background audio management
- `mcp/` — MCP server + SQLite FTS5 index for AI-assisted discovery
- `COMPONENTS.md` — Package API catalog (source of truth for MCP index)

## Conventions

- **Platform guards** — WatchConnectivity code uses `#if canImport(WatchConnectivity) && os(iOS)` / `os(watchOS)`. Shader effects use `#if canImport(Metal)`. Always guard platform-specific code.
- **Theming** — UI components read colors/typography/spacing from `DonkeyTheme` via environment. Don't hardcode colors.
- **Public API** — All reusable types, views, modifiers, and helpers must be `public`. Use delegate protocols for app-specific customization.
- **No app-specific code** — This is a shared library. API clients, data models, and server URLs belong in the consuming app or in donkey-swift/donkeygo.

## Running tests

```sh
swift test
```

## Verifying build

```sh
swift build
```
