// Implement and use a custom ``BackoffAlgorithm`` type.

// snippet.hide

import Retry

// snippet.show

struct MyBackoffAlgorithm<ClockType: Clock>: BackoffAlgorithm {
   private let clock: ClockType

   private var attempt = 0

   init(clock: ClockType) {
      self.clock = clock
   }

   mutating func nextDelay() -> ClockType.Duration {
      defer {
         attempt += 1
      }

      // Dummy algorithm for illustration.
      return clock.minimumResolution * attempt
   }
}

try await retry(backoff: Backoff { MyBackoffAlgorithm(clock: $0) }) {
   try await doSomething()
}

// snippet.hide

func doSomething() async throws {
}
