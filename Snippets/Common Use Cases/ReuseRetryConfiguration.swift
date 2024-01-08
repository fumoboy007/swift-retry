// Encapsulate retry behavior in a ``RetryConfiguration`` instance.

// snippet.hide

import Logging
import Retry

// snippet.show

extension RetryConfiguration where ClockType.Duration == Duration {
   static func standard(using clock: ClockType = ContinuousClock()) -> Self {
      return RetryConfiguration(
         clock: clock,
         recoverFromFailure: { $0.isRetryable ? .retry : .throw }
      )
   }

   static func highTolerance(using clock: ClockType = ContinuousClock()) -> Self {
      return standard(using: clock)
         .withMaxAttempts(10)
         .withBackoff(.default(baseDelay: .seconds(1),
                               maxDelay: nil))
   }
}

try await retry(with: .highTolerance().withLogger(myLogger)) {
   try await doSomething()
}

// snippet.hide

extension Error {
   var isRetryable: Bool {
      return true
   }
}

let myLogger = Logger(label: "Example Code")

func doSomething() async throws {
}
