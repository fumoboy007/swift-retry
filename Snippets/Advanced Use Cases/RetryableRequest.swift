// Conform a request type to ``RetryableRequest`` to add safe retry methods to the request type.

// snippet.hide

import Retry

// snippet.show

extension MyRequest: RetryableRequest {
   var isIdempotent: Bool {
      // ...
      // snippet.hide
      return true
      // snippet.show
   }

   func unsafeRetryIgnoringIdempotency<ClockType, ReturnType>(
      with configuration: RetryConfiguration<ClockType>,
      @_inheritActorContext @_implicitSelfCapture operation: (Self) async throws -> ReturnType
   ) async throws -> ReturnType {
      // We can override the `recoverFromFailure` closure to automatically handle errors
      // specific to the communication protocol.
      let configuration = configuration.withRecoverFromFailure { error in
         switch error {
         case is MyTransientCommunicationError:
            return .retry

         case is MyNonTransientCommunicationError:
            return .throw

         default:
            return configuration.recoverFromFailure(error)
         }
      }

      return try await Retry.retry(with: configuration) {
         return try await operation(self)
      }
   }
}

// snippet.hide

let myRequest = MyRequest()

// snippet.show

try await myRequest.retry { request in
   try await perform(request)
}

// snippet.hide

struct MyRequest {
}

enum MyTransientCommunicationError: Error {
}

enum MyNonTransientCommunicationError: Error {
}

func perform(_ request: MyRequest) async throws {
}
