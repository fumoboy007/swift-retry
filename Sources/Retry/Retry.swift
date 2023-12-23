// MIT License
//
// Copyright © 2023 Darren Mo.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Logging
#if canImport(OSLog)
import OSLog
#endif

#if canImport(OSLog)
/// Attempts the given operation until it succeeds or until the failure is no longer retryable.
/// Sleeps in between attempts using `ContinuousClock`.
///
/// Failures may not be retryable for the following reasons:
/// - `shouldRetry` returns `false`.
/// - The thrown error is ``NotRetryable``.
/// - The number of attempts reached `maxAttempts`.
///
/// - Parameters:
///    - maxAttempts: The maximum number of times to attempt the operation. Must be greater than `0`.
///    - backoff: The choice of algorithm that will be used to determine how long to sleep in between attempts.
///    - appleLogger: The logger that will be used to log a message when an attempt fails. The function will
///       log messages using the `debug` log level.
///    - logger: The logger that will be used to log a message when an attempt fails. The function will log
///       messages using the `debug` log level. Consider using `appleLogger` when possible.
///    - operation: The operation to attempt.
///    - shouldRetry: A closure that determines whether to retry, given the error that was thrown. The closure
///       will not be called if the error is ``Retryable`` or ``NotRetryable``.
///
/// - SeeAlso: ``retry(with:operation:)``
public func retry<ReturnType>(
   maxAttempts: Int? = 3,
   backoff: Backoff<ContinuousClock> = .default(baseDelay: .seconds(1), maxDelay: .seconds(20)),
   appleLogger: os.Logger? = nil,
   logger: Logging.Logger? = nil,
   @_inheritActorContext @_implicitSelfCapture operation: () async throws -> ReturnType,
   shouldRetry: @escaping @Sendable (any Error) -> Bool = { _ in true }
) async throws -> ReturnType {
   return try await retry(maxAttempts: maxAttempts,
                          clock: ContinuousClock(),
                          backoff: backoff,
                          appleLogger: appleLogger,
                          logger: logger,
                          operation: operation,
                          shouldRetry: shouldRetry)
}

/// Attempts the given operation until it succeeds or until the failure is no longer retryable.
/// Sleeps in between attempts using the given clock whose duration type is the standard `Duration` type.
///
/// Failures may not be retryable for the following reasons:
/// - `shouldRetry` returns `false`.
/// - The thrown error is ``NotRetryable``.
/// - The number of attempts reached `maxAttempts`.
///
/// - Parameters:
///    - maxAttempts: The maximum number of times to attempt the operation. Must be greater than `0`.
///    - clock: The clock that will be used to sleep in between attempts.
///    - backoff: The choice of algorithm that will be used to determine how long to sleep in between attempts.
///    - appleLogger: The logger that will be used to log a message when an attempt fails. The function will
///       log messages using the `debug` log level.
///    - logger: The logger that will be used to log a message when an attempt fails. The function will log
///       messages using the `debug` log level. Consider using `appleLogger` when possible.
///    - operation: The operation to attempt.
///    - shouldRetry: A closure that determines whether to retry, given the error that was thrown. The closure
///       will not be called if the error is ``Retryable`` or ``NotRetryable``.
///
/// - SeeAlso: ``retry(with:operation:)``
public func retry<ClockType, ReturnType>(
   maxAttempts: Int? = 3,
   clock: ClockType,
   backoff: Backoff<ClockType> = .default(baseDelay: .seconds(1), maxDelay: .seconds(20)),
   appleLogger: os.Logger? = nil,
   logger: Logging.Logger? = nil,
   @_inheritActorContext @_implicitSelfCapture operation: () async throws -> ReturnType,
   shouldRetry: @escaping @Sendable (any Error) -> Bool = { _ in true }
) async throws -> ReturnType where ClockType.Duration == Duration {
   let configuration = RetryConfiguration(maxAttempts: maxAttempts,
                                          clock: clock,
                                          backoff: backoff,
                                          appleLogger: appleLogger,
                                          logger: logger,
                                          shouldRetry: shouldRetry)

   return try await retry(with: configuration,
                          operation: operation)
}

/// Attempts the given operation until it succeeds or until the failure is no longer retryable.
/// Sleeps in between attempts using the given clock.
///
/// Failures may not be retryable for the following reasons:
/// - `shouldRetry` returns `false`.
/// - The thrown error is ``NotRetryable``.
/// - The number of attempts reached `maxAttempts`.
///
/// - Parameters:
///    - maxAttempts: The maximum number of times to attempt the operation. Must be greater than `0`.
///    - clock: The clock that will be used to sleep in between attempts.
///    - backoff: The choice of algorithm that will be used to determine how long to sleep in between attempts.
///    - appleLogger: The logger that will be used to log a message when an attempt fails. The function will
///       log messages using the `debug` log level.
///    - logger: The logger that will be used to log a message when an attempt fails. The function will log
///       messages using the `debug` log level. Consider using `appleLogger` when possible.
///    - operation: The operation to attempt.
///    - shouldRetry: A closure that determines whether to retry, given the error that was thrown. The closure
///       will not be called if the error is ``Retryable`` or ``NotRetryable``.
///
/// - SeeAlso: ``retry(with:operation:)``
public func retry<ClockType, ReturnType>(
   maxAttempts: Int? = 3,
   clock: ClockType,
   backoff: Backoff<ClockType>,
   appleLogger: os.Logger? = nil,
   logger: Logging.Logger? = nil,
   @_inheritActorContext @_implicitSelfCapture operation: () async throws -> ReturnType,
   shouldRetry: @escaping @Sendable (any Error) -> Bool = { _ in true }
) async throws -> ReturnType {
   let configuration = RetryConfiguration(maxAttempts: maxAttempts,
                                          clock: clock,
                                          backoff: backoff,
                                          appleLogger: appleLogger,
                                          logger: logger,
                                          shouldRetry: shouldRetry)

   return try await retry(with: configuration,
                          operation: operation)
}
#else
/// Attempts the given operation until it succeeds or until the failure is no longer retryable.
/// Sleeps in between attempts using `ContinuousClock`.
///
/// Failures may not be retryable for the following reasons:
/// - `shouldRetry` returns `false`.
/// - The thrown error is ``NotRetryable``.
/// - The number of attempts reached `maxAttempts`.
///
/// - Parameters:
///    - maxAttempts: The maximum number of times to attempt the operation. Must be greater than `0`.
///    - backoff: The choice of algorithm that will be used to determine how long to sleep in between attempts.
///    - logger: The logger that will be used to log a message when an attempt fails. The function will log
///       messages using the `debug` log level.
///    - operation: The operation to attempt.
///    - shouldRetry: A closure that determines whether to retry, given the error that was thrown. The closure
///       will not be called if the error is ``Retryable`` or ``NotRetryable``.
///
/// - SeeAlso: ``retry(with:operation:)``
public func retry<ReturnType>(
   maxAttempts: Int? = 3,
   backoff: Backoff<ContinuousClock> = .default(baseDelay: .seconds(1), maxDelay: .seconds(20)),
   logger: Logging.Logger? = nil,
   @_inheritActorContext @_implicitSelfCapture operation: () async throws -> ReturnType,
   shouldRetry: @escaping @Sendable (any Error) -> Bool = { _ in true }
) async throws -> ReturnType {
   return try await retry(maxAttempts: maxAttempts,
                          clock: ContinuousClock(),
                          backoff: backoff,
                          logger: logger,
                          operation: operation,
                          shouldRetry: shouldRetry)
}

/// Attempts the given operation until it succeeds or until the failure is no longer retryable.
/// Sleeps in between attempts using the given clock whose duration type is the standard `Duration` type.
///
/// Failures may not be retryable for the following reasons:
/// - `shouldRetry` returns `false`.
/// - The thrown error is ``NotRetryable``.
/// - The number of attempts reached `maxAttempts`.
///
/// - Parameters:
///    - maxAttempts: The maximum number of times to attempt the operation. Must be greater than `0`.
///    - clock: The clock that will be used to sleep in between attempts.
///    - backoff: The choice of algorithm that will be used to determine how long to sleep in between attempts.
///    - logger: The logger that will be used to log a message when an attempt fails. The function will log
///       messages using the `debug` log level.
///    - operation: The operation to attempt.
///    - shouldRetry: A closure that determines whether to retry, given the error that was thrown. The closure
///       will not be called if the error is ``Retryable`` or ``NotRetryable``.
///
/// - SeeAlso: ``retry(with:operation:)``
public func retry<ClockType, ReturnType>(
   maxAttempts: Int? = 3,
   clock: ClockType,
   backoff: Backoff<ClockType> = .default(baseDelay: .seconds(1), maxDelay: .seconds(20)),
   logger: Logging.Logger? = nil,
   @_inheritActorContext @_implicitSelfCapture operation: () async throws -> ReturnType,
   shouldRetry: @escaping @Sendable (any Error) -> Bool = { _ in true }
) async throws -> ReturnType where ClockType.Duration == Duration {
   let configuration = RetryConfiguration(maxAttempts: maxAttempts,
                                          clock: clock,
                                          backoff: backoff,
                                          logger: logger,
                                          shouldRetry: shouldRetry)

   return try await retry(with: configuration,
                          operation: operation)
}

/// Attempts the given operation until it succeeds or until the failure is no longer retryable.
/// Sleeps in between attempts using the given clock.
///
/// Failures may not be retryable for the following reasons:
/// - `shouldRetry` returns `false`.
/// - The thrown error is ``NotRetryable``.
/// - The number of attempts reached `maxAttempts`.
///
/// - Parameters:
///    - maxAttempts: The maximum number of times to attempt the operation. Must be greater than `0`.
///    - clock: The clock that will be used to sleep in between attempts.
///    - backoff: The choice of algorithm that will be used to determine how long to sleep in between attempts.
///    - logger: The logger that will be used to log a message when an attempt fails. The function will log
///       messages using the `debug` log level.
///    - operation: The operation to attempt.
///    - shouldRetry: A closure that determines whether to retry, given the error that was thrown. The closure
///       will not be called if the error is ``Retryable`` or ``NotRetryable``.
///
/// - SeeAlso: ``retry(with:operation:)``
public func retry<ClockType, ReturnType>(
   maxAttempts: Int? = 3,
   clock: ClockType,
   backoff: Backoff<ClockType>,
   logger: Logging.Logger? = nil,
   @_inheritActorContext @_implicitSelfCapture operation: () async throws -> ReturnType,
   shouldRetry: @escaping @Sendable (any Error) -> Bool = { _ in true }
) async throws -> ReturnType {
   let configuration = RetryConfiguration(maxAttempts: maxAttempts,
                                          clock: clock,
                                          backoff: backoff,
                                          logger: logger,
                                          shouldRetry: shouldRetry)

   return try await retry(with: configuration,
                          operation: operation)
}
#endif

/// Attempts the given operation until it succeeds or until the failure is no longer retryable.
///
/// Failures may not be retryable for the following reasons:
/// - ``RetryConfiguration/shouldRetry`` returns `false`.
/// - The thrown error is ``NotRetryable``.
/// - The number of attempts reached ``RetryConfiguration/maxAttempts``.
///
/// - Parameters:
///    - configuration: Configuration that specifies the behavior of this function.
///    - operation: The operation to attempt.
///
/// - Note: The function will log messages using the `debug` log level to ``RetryConfiguration/logger``
///    (and/or ``RetryConfiguration/appleLogger`` on Apple platforms).
public func retry<ClockType, ReturnType>(
   with configuration: RetryConfiguration<ClockType>,
   @_inheritActorContext @_implicitSelfCapture operation: () async throws -> ReturnType
) async throws -> ReturnType {
   let maxAttempts = configuration.maxAttempts

   let clock = configuration.clock
   var backoff = configuration.backoff.makeAlgorithm(clock: clock)

   var logger = configuration.logger
#if canImport(OSLog)
   let appleLogger = configuration.appleLogger
#endif

   let shouldRetry = configuration.shouldRetry

   var attempt = 0
   while true {
      var latestError: any Error
      var isErrorRetryable: Bool

      do {
         return try await operation()
      } catch {
         switch error {
         case let error as Retryable:
            latestError = error
            isErrorRetryable = true

         case let error as NotRetryable:
            latestError = error
            isErrorRetryable = false

         default:
            latestError = error
            isErrorRetryable = shouldRetry(error)
         }

         latestError = latestError.originalError

         if latestError is CancellationError {
            isErrorRetryable = false
         }
      }

      logger?[metadataKey: "retry.attempt"] = "\(attempt)"
      // Only log the error type rather than the full error in case the error has private user data.
      // We can include the full error if and when the `Logging` API offers a distinction between
      // public and private data.
      logger?[metadataKey: "retry.error.type"] = "\(type(of: latestError))"

      if !isErrorRetryable {
         logger?.debug("Attempt failed. Error is not retryable.")
#if canImport(OSLog)
         appleLogger?.debug("""
            Attempt \(attempt, privacy: .public) failed with error of type `\(type(of: latestError), privacy: .public)`: `\(latestError)`. \
            Error is not retryable.
            """)
#endif

         throw latestError
      }

      if let maxAttempts, attempt + 1 >= maxAttempts {
         logger?.debug("Attempt failed. No remaining attempts.")
#if canImport(OSLog)
         appleLogger?.debug("""
            Attempt \(attempt, privacy: .public) failed with error of type `\(type(of: latestError), privacy: .public)`: `\(latestError)`. \
            No remaining attempts.
            """)
#endif

         throw latestError
      }

      let delay = backoff.nextDelay() as! ClockType.Duration

      logger?.debug("Attempt failed. Will wait before retrying.", metadata: [
         // Unfortunately, the generic `ClockType.Duration` does not have a way to convert `delay`
         // to a number, so we have to settle for the implementation-defined string representation.
         "retry.delay": "\(delay)"
      ])
#if canImport(OSLog)
      appleLogger?.debug("""
         Attempt \(attempt, privacy: .public) failed with error of type `\(type(of: latestError), privacy: .public)`: `\(latestError)`. \
         Will wait \(String(describing: delay), privacy: .public) before retrying.
         """)
#endif

      try await clock.sleep(for: delay)

      attempt += 1
   }
}
