// Retry an operation using the default retry behavior.

// snippet.hide

import Retry

// snippet.show

try await retry {
   try await doSomething()
}

// snippet.hide

func doSomething() async throws {
}
