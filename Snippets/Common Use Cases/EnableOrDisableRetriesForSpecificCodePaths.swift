// Enable or disable retries based on which suboperation failed.

// snippet.hide

import Retry

// snippet.show

try await retry {
   do {
      try await doSomethingRetryable()
   } catch {
      throw Retryable(error)
   }

   do {
      try await doSomethingNotRetryable()
   } catch {
      throw NotRetryable(error)
   }
}

// snippet.hide

func doSomethingRetryable() async throws {
}

func doSomethingNotRetryable() async throws {
}
