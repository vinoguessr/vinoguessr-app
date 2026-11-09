import Foundation
import Testing

extension Trait where Self == ConditionTrait {
  /// Enables a suite only when the `VINOGUESSR_LIVE_API_TESTS` environment variable is `1`.
  ///
  /// Live suites call the production API, and `APIWriteTests` creates records there, so they are
  /// opt-in instead of part of every run; CI runs only the offline suites. `xcodebuild test`
  /// forwards the variable to the test runner only with a `TEST_RUNNER_` prefix.
  static var liveAPI: Self {
    .enabled(
      if: ProcessInfo.processInfo.environment["VINOGUESSR_LIVE_API_TESTS"] == "1",
      "Calls the production VinoGuessr API; set VINOGUESSR_LIVE_API_TESTS=1 to run"
    )
  }
}
