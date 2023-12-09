// Configure the retry behavior.

// snippet.hide

import Logging
import Retry

// snippet.show

try await retry(maxAttempts: 5,
                backoff: .default(baseDelay: .milliseconds(500),
                                  maxDelay: .seconds(10)),
                logger: myLogger) {
   try await doSomething()
}

// snippet.hide

let myLogger = Logger(label: "Example Code")

func doSomething() async throws {
}
