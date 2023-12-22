// Encapsulate retry behavior in a ``RetryConfiguration`` instance.

// snippet.hide

import Logging
import Retry

// snippet.show

extension RetryConfiguration<ContinuousClock> {
   static let standard = RetryConfiguration(shouldRetry: { $0.isRetryable })

   static let highTolerance = (
      Self.standard
         .withMaxAttempts(10)
         .withBackoff(.default(baseDelay: .seconds(1),
                               maxDelay: nil))
   )
}

try await retry(with: .highTolerance.withLogger(myLogger)) {
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
