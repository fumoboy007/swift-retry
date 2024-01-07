// Sleep a minimum duration before the next attempt.

// snippet.hide

import Retry

// snippet.show

try await retry {
   try await doSomething()
} recoverFromFailure: { error in
   switch error {
   case let error as MyRetryAwareServerError:
      return .retryAfter(ContinuousClock().now + error.minRetryDelay)

   default:
      return .retry
   }
}

// snippet.hide

func doSomething() async throws {
}

struct MyRetryAwareServerError: Error {
   let minRetryDelay: Duration
}
