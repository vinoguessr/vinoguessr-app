# VinoGuessr
VinoGuessr app for iOS and iPadOS

<!-- vinoguessr-foundation -->
## Scope

SwiftUI app for players. iOS and iPadOS 27.0 or later; macOS and visionOS are deferred ([ADR-0006](https://github.com/vinoguessr/vinoguessr-docs/blob/main/docs/adr/0006-app-platforms.md)). Provides the UI for creating events, setting questions, answering, scoring, and the player's page.

## Architecture

The VinoGuessr API is the source of truth. Sign-in uses passkeys and email one-time codes. Tokens are stored in the Keychain, and scores or participation are never finalized from app-side values.

## Verification

After implementing, build the `VinoGuessr` app for the iOS Simulator with the target Xcode, run the `VinoGuessrKit` tests on an iOS Simulator (the app target has no tests of its own), and check the main flows with Xcode MCP and the Simulator. `VinoGuessrKit` does not build for the macOS host, so use `xcodebuild` instead of `swift test`:

```sh
xcodebuild build -project VinoGuessr.xcodeproj -scheme VinoGuessr -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO
cd VinoGuessrKit && xcodebuild test -scheme VinoGuessrKit -destination 'platform=iOS Simulator,name=iPhone 17'
```

`APIReadTests` and `APIWriteTests` call the production API, and `APIWriteTests` creates records there, so they run only when `VINOGUESSR_LIVE_API_TESTS=1`; `xcodebuild test` forwards it to the tests only as `TEST_RUNNER_VINOGUESSR_LIVE_API_TESTS=1`. The `Build and test` workflow runs the same build and the offline tests on every PR.

Do not add compatibility branches for older OS versions.

Follow [AGENTS.md](AGENTS.md) and [CONTRIBUTING.md](CONTRIBUTING.md): satisfy the Issue's dependencies, then implement with an independent Review Agent running in parallel. Shared rules source: [vinoguessr/.github@01fd9c61bce2](https://github.com/vinoguessr/.github/tree/01fd9c61bce2139beb8ea173339d45c02d49b69f).
