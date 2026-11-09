# VinoGuessr — Shared Agent Rules

The source of truth for these rules is `vinoguessr/.github/AGENTS.md`. Every repository carries an effective copy of these rules plus its own verification commands. Do not assume a link alone makes the rules apply.

## Writing language

Write code, documentation, commit messages, labels, and PR titles in English. PRs are squash-merged with the PR title as the commit subject, so a PR title is a commit message. Write Issue bodies and PR bodies in Japanese. Issue Forms and the PR template stay in Japanese because they become the Issue and PR body.

## Purpose and architecture

VinoGuessr is a service for blind wine tasting: people create events, set questions, answer them, get scored, and build a season rating. The VinoGuessr API and PostgreSQL are the source of truth for business data such as users, events, questions, answers, and scores. External services are never the source of truth.

API: Swift 6 / Hummingbird / PostgreSQL / PostgresNIO / Valkey / Atlas / OpenAPI. Apple: SwiftUI, iOS, iPadOS, and macOS 27.0 or later. Web: Swift / Hummingbird. Infrastructure: Terraform / Google Cloud Run / Cloudflare (DNS, Images, Email) / Docker / OpenTelemetry. Target the latest stable OS and browser releases and do not add unnecessary backward-compatibility branches.

Sign-in uses passkeys (WebAuthn) and email one-time codes. Sessions use tokens issued by the API; never trust a user ID or event participation state sent by a client. Images are served through Cloudflare Images, and event tickets are Apple Wallet passes.

## Implementation flow and roles

1. Read the Issue, acceptance criteria, sub-issues, dependencies, existing PRs, and ADRs. Check for duplicates and blockers.
2. Make an implementation plan. While the Coding Agent implements, always run an independent Review Agent in parallel. Use a review from a separate context; the implementer re-reading its own work does not count.
3. When a change touches authentication (passkeys, email one-time codes, tokens), personal data, event participation authorization, scoring integrity, or Apple Wallet pass signing, also run a Security Review Agent in parallel. The Bug Triage Agent reproduces bugs and checks for duplicates; the Tool Review Agent checks permissions and execution safety of MCP servers, Skills, and CI.
4. Fix findings and actually run builds, tests, and any required runtime checks. Never pass a change on AI review alone. For bugs, search for duplicates, open an Issue if needed, and add a regression test.
5. After re-review, confirm GitHub Actions succeeded, and record the implementation, verification, review results, and open items in the PR. Never describe an unrun check as passing.

If parallel agents are unavailable, record that constraint and do not merge until the review conditions are met. A review does not automatically become a GitHub approval.

## Coding and testing

Respect the existing structure and keep changes small and scoped to one Issue. Enable Swift 6 concurrency checking and avoid unjustified `@unchecked Sendable` or swallowed errors. Define public APIs in OpenAPI first and never hand-edit generated code. Database changes come with a versioned, forward-only Atlas migration and integration tests.

For the API run `swift build` / `swift test` with integration tests against PostgreSQL and Valkey, and verify Atlas migrations. For the web run `swift build` / `swift test`. For Apple run build/test with the target Xcode and check required flows in the Simulator. For Terraform run `fmt` / `init -backend=false` / `validate`. A foundation PR without code runs structural checks only and must not be recorded as app-verified.

When changing the shared foundation in the `.github` repository, verify with `python scripts/validate_repository.py` (Python 3.11 or later, using `scripts/validation-requirements.txt`), `python -m unittest discover -s scripts -p 'test_*.py'`, and `actionlint`. Other repositories use the repository-specific section at the end of their AGENTS.md and the real verification steps in their README. Enable reusable workflows only after the calling repository actually has the code, lockfile, and tests.

## What each artifact explains

- **Code explains how**: express the implementation through structure, names, and logic.
- **Tests explain what**: state the expected behavior and the guaranteed result.
- **Commit messages explain why**: record why the change is needed and which problem it solves.
- **Code comments explain why not**: explain why alternatives were rejected and which constraints apply.

## Tracking workarounds

When you introduce an implementation or operation that temporarily works around a defect or constraint, check for related Issues and either add to an existing one or open a tracking Issue. Do not label a permanent design or a reasonable setting as a workaround without evidence.

A tracking Issue records why it was introduced, the impact, the affected code and PR, the permanent fix, the condition for removing it, upstream Issues/PRs if any, when to recheck, and the regression check. Leave a why-not comment with the constraint and the Issue reference at the relevant code, and reference the tracking Issue from the introducing PR.

The introducing PR references the tracking Issue without auto-close keywords. Close the tracking Issue only after the removal condition and the regression check confirm that the permanent fix landed or the workaround is no longer needed.

## Security

Never leave secrets, tokens, personal data, or real user data in code, logs, Issues, or PRs. Never print credential values. Verify that a passkey's challenge, origin, and RP ID match, and rate-limit one-time code and token issuance. The API verifies event participation and every write of answers and scores against a trusted session, and never finalizes a score from a client-supplied value. Never commit Apple Wallet pass signing keys or certificates (`.p12`, `.p8`, and similar).

Creating billed resources, production deploys, `terraform apply`, and broad IAM grants require explicit approval. Keep PII and credentials out of OpenTelemetry. Workflows use least-privilege permissions, and external actions are pinned to full commit SHAs. Shared reusable workflows are referenced by a SHA retained in the default branch history, never by an unmerged branch's SHA. Do not persist checkout credentials. Never run untrusted PR code with `pull_request_target`.

## MCP servers and Skills

At the start, check which MCP servers, Skills, and CLIs are actually available. Use the GitHub CLI, PostgreSQL and Atlas, Xcode MCP, the Simulator, SwiftUI Expert, Swift Build, Terraform, and gcloud as the task requires. Verify the official installation method and terms before installing anything locally. Do not expand system settings, authentication, or permissions without approval. Record unavailable tools along with the alternative command and what remains unverified. Distinguish installed from actually used.

## GitHub operations and documentation

Use `codex/` branches and PRs; never push directly to `main`. Never overwrite existing changes, repositories, or licenses. Do not send messages to other people beyond the required GitHub Issue and Project updates unless explicitly asked. Add Issues to the cross-repository Project and record acceptance criteria and real dependencies. Handle confidential vulnerabilities through SECURITY.md, not public Issues.

A PR records the related Issue, what changes, the checks run and their results, independent Review and Security Review results, and known limitations. Never fake required checks by skipping them. Releases have a tested commit and a changelog; Environments separate the approval boundaries of development, staging, and production. Use Packages only when there is something to distribute.

Record significant design changes as ADRs in `vinoguessr-docs` with context, decision, alternatives, and consequences, and update the wiki index. Update these rules and each repository's AGENTS.md as needed when bugs recur or a review finding matters. When the shared rules change, open follow-up PRs in the other repositories and state the source commit.

## Code review and merge conditions

1. Check the automatic Codex review on the PR. Verify the basis of each finding and make the required code fixes and regression tests.
2. Reply to each review thread with the fix, the commit, and the verification result. If no change is needed, explain why and do not hide open items.
3. After addressing findings, comment exactly `@codex review` on the PR to request a new review, and wait for the review of the latest commit.
4. Repeat for any new findings. Merge only after GitHub Codex reports no findings, no findings remain unaddressed, and the required CI has passed.
5. A missing review, a missing integration, or a failed run does not mean "no findings". Record the cause and the request URL, and keep the PR open. A passing independent local Review Agent does not replace this condition; the only exception is the usage-limit substitute below.

**Only when Codex cannot review because of its usage limit (insufficient tokens), a Claude Code independent review may substitute.** When substituting:

- After Codex reports its usage limit, run Claude Code's `reviewer` agent (`.claude/agents/reviewer.md`) as a separate run against the latest commit, in a context separate from the implementing agent. A review run during implementation never counts as the substitute. For changes to authentication, personal data, event participation authorization, scoring, or Apple Wallet pass signing, also run `security-reviewer`.
- Record in the PR the evidence that Codex was unavailable (the limit message and the URL of the request comment), the reviewed commit, and the findings and fixes.
- After fixing findings, review the latest commit again, and merge only once there are no findings and the required CI has passed.
- Reasons other than the usage limit (no response, missing integration, failed run) do not qualify for substitution. Investigate and record the cause, and keep the PR open.

This GitHub review is in addition to the independent Review Agent running in parallel during implementation and to real builds and tests. Requesting a review does not count as passing. Avoid automated replies and repeated identical requests, and record each review round and its commit in the PR.

## vinoguessr-app specifics

Shared rules source: `vinoguessr/.github@38adaa6afdfb7df020feb2a7ff93a6ddf1d79af8`.

SwiftUI app for players. iOS, iPadOS, and macOS 27.0 or later. Provides the UI for creating events, setting questions, answering, scoring, and the player's page.

The VinoGuessr API is the source of truth. Sign-in uses passkeys and email one-time codes. Tokens are stored in the Keychain, and scores or participation are never finalized from app-side values.

After implementing, build the `VinoGuessr` app with the target Xcode, run `swift test` for `VinoGuessrKit` (the app target has no tests of its own), and check the main flows with Xcode MCP and the Simulator. Do not add compatibility branches for older OS versions.

## SwiftUI policy — iOS/iPadOS/macOS 27.0+

Scope: SwiftUI work in `vinoguessr-app`. Read the available SwiftUI Expert Skill; project requirements override generic older-OS fallback advice. Verify availability against the deployment target and selected SDK. Do not impose an architecture or adopt Liquid Glass automatically.

### Layout

Start with standard containers. Select `Layout` for placement, `onGeometryChange` for observation, `alignmentGuide` for relationships, Subview APIs for containers, `ArrangementView` for custom two-region relationships. Check `ViewThatFits`/`fixedSize` sizing. `if` removes; `opacity`/`hidden` reserve space. Check invisible accessibility/hit testing. `GeometryReader` needs a geometry-driven purpose; prevent feedback loops. `Layout` is not lazy virtualization. [User reference](https://zenn.dev/zunda_pixel/articles/2cc489b4168a5a)

### Two-region arrangements

Prefer standard adaptive navigation/content containers when they fit. Consider `ArrangementView` for custom split or foreground/background relationships; it does not supply navigation. Follow Apple's container-nesting guidance.

Before choosing a style, decide which content can disappear and which belongs in front. A constrained split may show only primary; a stacked overlay places primary above secondary. These roles are not interchangeable. Keep needed secondary information/actions reachable through another presentation. Sizing preferences do not prove the final layout.

Keep state that must survive conditional style/container branches above those identity boundaries. Verify continuity rather than assuming hidden content or a style switch preserves state. Do not infer complete visibility from `splitArrangementAxis`, `overlayArrangementZIndex` or reserved-region signals alone.

The article's Xcode 27.1 beta animation/API observations are context, not permanent platform guarantees. Recheck the selected SDK before adding a workaround. [User reference](https://fatbobman.com/zh/posts/arrangementview-think-before-you-arrange/), [Apple arrangements](https://developer.apple.com/documentation/swiftui/arrangementview), [Apple design guidance](https://developer.apple.com/videos/play/tech-talks/111463/).

### Identity and ownership

Identity controls state lifetime; changing initializer arguments does not reset existing state. Use stable model IDs. Change `.id` or conditional containers only for intentional lifetime changes. Do not treat inferred List caches as API contracts. [User reference](https://zenn.dev/zunda_pixel/articles/ea826f888d05ed)

Keep primitive view-local `@State` private. Preserve owned observable models with `@State`; use `@Bindable` for injected edits and plain values for read-only inputs. An initial value seeds that identity's storage; `View.init` may run again. Later parent updates need values or bindings. UI-owned observable models/routers use explicit `@MainActor` under our nonisolated default.

### Observation

Prefer property-granular `@Observable` models and small dependency boundaries. A class alone does not guarantee faster rendering. Measure actual UI updates rather than generalizing old benchmark counts; do not eliminate appropriate primitive state. [User reference](https://zenn.dev/zunda_pixel/articles/9ce01609d0d234)

### Navigation

Default to an exhaustive `Hashable` route enum with stable IDs and `[Route]`; use `NavigationPath` when heterogeneous types are needed. Own the router at its scope and inject through `@Environment`. Modernize legacy wrappers. Never derive a retroactive `Binding: Hashable` from mutable wrapped values. [User reference](https://zenn.dev/zunda_pixel/articles/ebf2a079cbf68b)

Own routers per scene/account/profile; key private presentation caches by environment/account/event too. Clear authenticated presentation on logout, revocation or identity changes; discard late results from a previous identity/scope. Keep token/CSRF handling in the existing session layer, not UI state or navigation persistence. Routes contain IDs, not credentials or full private models. Authorized display models remain allowed. Restored IDs/deep links require API authorization; UI state grants no access. Preserve redacted errors.

### Actions and toolbars

Define an action's purpose before its position. Prefer suitable semantic toolbar placements; reconsider competing actions before fixing physical edges. Choose `ButtonRole` to match behavior: `.close` preserves progress, `.cancel` abandons the pending operation, `.confirm` confirms, and `.destructive` identifies destructive work. Roles do not implement application save/discard logic or grant API authorization; handlers and presentation policy must implement the promised behavior. Use system role labels when appropriate and clear contextual labels when needed. Custom placement or content actions remain valid when justified. Verify unsaved-change dismissal, required destructive confirmation/undo, accessibility and compact/expanded toolbar overflow. [User reference](https://zenn.dev/zunda_pixel/articles/7ed1e0d8456e7c), [Apple ButtonRole](https://developer.apple.com/documentation/swiftui/buttonrole), [semantic placements](https://developer.apple.com/documentation/swiftui/toolbaritemplacement).

### Verification

For UI changes, build/test on the target SDK and check iPhone/iPad resizing, Dynamic Type, accessibility, state lifetime and back navigation. For arrangements, check applicable primary-only, split and overlay outcomes, secondary access and state continuity. Profile performance when needed. Document-only changes verify policy parity/links; do not claim unexecuted UI or Instruments checks.

Apple contracts: [Observation migration](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro), [State](https://developer.apple.com/documentation/swiftui/state), [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack), [Layout](https://developer.apple.com/documentation/swiftui/layout), [ArrangementView](https://developer.apple.com/documentation/swiftui/arrangementview). Skill: [SwiftUI Agent Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill).

SwiftUI policy source: `vinoguessr/.github@38adaa6afdfb7df020feb2a7ff93a6ddf1d79af8:policies/swiftui.md`.
