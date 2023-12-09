// Specify which error cases are retryable.

// snippet.hide

import Retry

// snippet.show

try await retry {
   try await doSomething()
} shouldRetry: { error in
   return error.isRetryable
}

extension Error {
   var isRetryable: Bool {
      switch self {
      case let error as MyError:
         return error.isRetryable

      default:
         return true
      }
   }
}

extension MyError {
   var isRetryable: Bool {
      switch self {
      case .myRetryableCase:
         return true

      case .myNotRetryableCase:
         return false
      }
   }
}

// snippet.hide

func doSomething() async throws {
}

enum MyError: Error {
   case myRetryableCase
   case myNotRetryableCase
}
