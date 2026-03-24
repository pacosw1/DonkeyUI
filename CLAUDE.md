# DonkeyUI

SwiftUI component library for iOS 17+ / macOS 14+. Distributed via Swift Package Manager.

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
  - `Theme/` — Semantic theming system
  - `Auth/` — DonkeyAuthManager (Apple Sign In)
  - `Store/` — DonkeyStoreManager (StoreKit 2)
- `mcp/` — MCP server + SQLite FTS5 index for AI-assisted discovery
- `COMPONENTS.md` — Auto-maintained component catalog (source of truth for MCP index)
