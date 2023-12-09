// Encapsulate retry behavior in a ``RetryConfiguration`` instance.

// snippet.hide

import Logging
import Retry

// snippet.show

extension RetryConfiguration<ContinuousClock> {
   static let highTolerance = RetryConfiguration(
      maxAttempts: 10,
      backoff: .default(baseDelay: .seconds(1),
                        maxDelay: nil),
      shouldRetry: { _ in true }
   )
}

try await retry(with: .highTolerance.withLogger(myLogger)) {
   try await doSomething()
}

// snippet.hide

let myLogger = Logger(label: "Example Code")

func doSomething() async throws {
}
