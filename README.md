# VinoGuessr
VinoGuessr app for iOS, iPadOS, and macOS

<!-- vinoguessr-foundation -->
## Scope

SwiftUI app for players. iOS, iPadOS, and macOS 27.0 or later. Provides the UI for creating events, setting questions, answering, scoring, and the player's page.

## Architecture

The VinoGuessr API is the source of truth. Sign-in uses passkeys and email one-time codes. Tokens are stored in the Keychain, and scores or participation are never finalized from app-side values.

## Verification

After implementing, build the `VinoGuessr` app with the target Xcode, run `swift test` for `VinoGuessrKit` (the app target has no tests of its own), and check the main flows with Xcode MCP and the Simulator. Do not add compatibility branches for older OS versions.

Follow [AGENTS.md](AGENTS.md) and [CONTRIBUTING.md](CONTRIBUTING.md): satisfy the Issue's dependencies, then implement with an independent Review Agent running in parallel. Shared rules source: [vinoguessr/.github@01fd9c61bce2](https://github.com/vinoguessr/.github/tree/01fd9c61bce2139beb8ea173339d45c02d49b69f).
