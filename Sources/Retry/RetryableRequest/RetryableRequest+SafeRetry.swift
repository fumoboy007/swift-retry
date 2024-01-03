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

extension RetryableRequest {
#if canImport(OSLog)
   /// Attempts the given operation until it succeeds or until the failure is no longer retryable.
   /// Sleeps in between attempts using `ContinuousClock`.
   ///
   /// Failures may not be retryable for the following reasons:
   /// - The response indicates that the failure is not transient.
   /// - `shouldRetry` returns `false`.
   /// - The thrown error is ``NotRetryable``.
   /// - The number of attempts reached `maxAttempts`.
   ///
   /// - Precondition: ``isIdempotent`` must return `true`.
   ///
   /// - Parameters:
   ///    - maxAttempts: The maximum number of times to attempt the operation. Must be greater than `0`.
   ///    - backoff: The choice of algorithm that will be used to determine how long to sleep in between attempts.
   ///    - appleLogger: The logger that will be used to log a message when an attempt fails. The function will
   ///       log messages using the `debug` log level.
   ///    - logger: The logger that will be used to log a message when an attempt fails. The function will log
   ///       messages using the `debug` log level. Consider using `appleLogger` when possible.
   ///    - operation: Attempts the given request.
   ///    - shouldRetry: A closure that determines whether to retry, given the error that was thrown. The closure
   ///       will not be called if the error is ``Retryable`` or ``NotRetryable``.
   ///
   /// - SeeAlso: ``retry(with:operation:)``
   public func retry<ReturnType>(
      maxAttempts: Int? = 3,
      backoff: Backoff<ContinuousClock> = .default(baseDelay: .seconds(1), maxDelay: .seconds(20)),
      appleLogger: os.Logger? = nil,
      logger: Logging.Logger? = nil,
      @_inheritActorContext @_implicitSelfCapture operation: (Self) async throws -> ReturnType,
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
   /// - The response indicates that the failure is not transient.
   /// - `shouldRetry` returns `false`.
   /// - The thrown error is ``NotRetryable``.
   /// - The number of attempts reached `maxAttempts`.
   ///
   /// - Precondition: ``isIdempotent`` must return `true`.
   ///
   /// - Parameters:
   ///    - maxAttempts: The maximum number of times to attempt the operation. Must be greater than `0`.
   ///    - clock: The clock that will be used to sleep in between attempts.
   ///    - backoff: The choice of algorithm that will be used to determine how long to sleep in between attempts.
   ///    - appleLogger: The logger that will be used to log a message when an attempt fails. The function will
   ///       log messages using the `debug` log level.
   ///    - logger: The logger that will be used to log a message when an attempt fails. The function will log
   ///       messages using the `debug` log level. Consider using `appleLogger` when possible.
   ///    - operation: Attempts the given request.
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
      @_inheritActorContext @_implicitSelfCapture operation: (Self) async throws -> ReturnType,
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
   /// - The response indicates that the failure is not transient.
   /// - `shouldRetry` returns `false`.
   /// - The thrown error is ``NotRetryable``.
   /// - The number of attempts reached `maxAttempts`.
   ///
   /// - Precondition: ``isIdempotent`` must return `true`.
   ///
   /// - Parameters:
   ///    - maxAttempts: The maximum number of times to attempt the operation. Must be greater than `0`.
   ///    - clock: The clock that will be used to sleep in between attempts.
   ///    - backoff: The choice of algorithm that will be used to determine how long to sleep in between attempts.
   ///    - appleLogger: The logger that will be used to log a message when an attempt fails. The function will
   ///       log messages using the `debug` log level.
   ///    - logger: The logger that will be used to log a message when an attempt fails. The function will log
   ///       messages using the `debug` log level. Consider using `appleLogger` when possible.
   ///    - operation: Attempts the given request.
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
      @_inheritActorContext @_implicitSelfCapture operation: (Self) async throws -> ReturnType,
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
   /// - The response indicates that the failure is not transient.
   /// - `shouldRetry` returns `false`.
   /// - The thrown error is ``NotRetryable``.
   /// - The number of attempts reached `maxAttempts`.
   ///
   /// - Precondition: ``isIdempotent`` must return `true`.
   ///
   /// - Parameters:
   ///    - maxAttempts: The maximum number of times to attempt the operation. Must be greater than `0`.
   ///    - backoff: The choice of algorithm that will be used to determine how long to sleep in between attempts.
   ///    - logger: The logger that will be used to log a message when an attempt fails. The function will log
   ///       messages using the `debug` log level.
   ///    - operation: Attempts the given request.
   ///    - shouldRetry: A closure that determines whether to retry, given the error that was thrown. The closure
   ///       will not be called if the error is ``Retryable`` or ``NotRetryable``.
   ///
   /// - SeeAlso: ``retry(with:operation:)``
   public func retry<ReturnType>(
      maxAttempts: Int? = 3,
      backoff: Backoff<ContinuousClock> = .default(baseDelay: .seconds(1), maxDelay: .seconds(20)),
      logger: Logging.Logger? = nil,
      @_inheritActorContext @_implicitSelfCapture operation: (Self) async throws -> ReturnType,
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
   /// - The response indicates that the failure is not transient.
   /// - `shouldRetry` returns `false`.
   /// - The thrown error is ``NotRetryable``.
   /// - The number of attempts reached `maxAttempts`.
   ///
   /// - Precondition: ``isIdempotent`` must return `true`.
   ///
   /// - Parameters:
   ///    - maxAttempts: The maximum number of times to attempt the operation. Must be greater than `0`.
   ///    - clock: The clock that will be used to sleep in between attempts.
   ///    - backoff: The choice of algorithm that will be used to determine how long to sleep in between attempts.
   ///    - logger: The logger that will be used to log a message when an attempt fails. The function will log
   ///       messages using the `debug` log level.
   ///    - operation: Attempts the given request.
   ///    - shouldRetry: A closure that determines whether to retry, given the error that was thrown. The closure
   ///       will not be called if the error is ``Retryable`` or ``NotRetryable``.
   ///
   /// - SeeAlso: ``retry(with:operation:)``
   public func retry<ClockType, ReturnType>(
      maxAttempts: Int? = 3,
      clock: ClockType,
      backoff: Backoff<ClockType> = .default(baseDelay: .seconds(1), maxDelay: .seconds(20)),
      logger: Logging.Logger? = nil,
      @_inheritActorContext @_implicitSelfCapture operation: (Self) async throws -> ReturnType,
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
   /// - The response indicates that the failure is not transient.
   /// - `shouldRetry` returns `false`.
   /// - The thrown error is ``NotRetryable``.
   /// - The number of attempts reached `maxAttempts`.
   ///
   /// - Precondition: ``isIdempotent`` must return `true`.
   ///
   /// - Parameters:
   ///    - maxAttempts: The maximum number of times to attempt the operation. Must be greater than `0`.
   ///    - clock: The clock that will be used to sleep in between attempts.
   ///    - backoff: The choice of algorithm that will be used to determine how long to sleep in between attempts.
   ///    - logger: The logger that will be used to log a message when an attempt fails. The function will log
   ///       messages using the `debug` log level.
   ///    - operation: Attempts the given request.
   ///    - shouldRetry: A closure that determines whether to retry, given the error that was thrown. The closure
   ///       will not be called if the error is ``Retryable`` or ``NotRetryable``.
   ///
   /// - SeeAlso: ``retry(with:operation:)``
   public func retry<ClockType, ReturnType>(
      maxAttempts: Int? = 3,
      clock: ClockType,
      backoff: Backoff<ClockType>,
      logger: Logging.Logger? = nil,
      @_inheritActorContext @_implicitSelfCapture operation: (Self) async throws -> ReturnType,
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
   /// - The response indicates that the failure is not transient. 
   /// - ``RetryConfiguration/shouldRetry`` returns `false`.
   /// - The thrown error is ``NotRetryable``.
   /// - The number of attempts reached ``RetryConfiguration/maxAttempts``.
   ///
   /// - Precondition: ``isIdempotent`` must return `true`.
   ///
   /// - Parameters:
   ///    - configuration: Configuration that specifies the behavior of this function.
   ///    - operation: Attempts the given request.
   ///
   /// - Note: The function will log messages using the `debug` log level to ``RetryConfiguration/logger``
   ///    (and/or ``RetryConfiguration/appleLogger`` on Apple platforms).
   public func retry<ClockType, ReturnType>(
      with configuration: RetryConfiguration<ClockType>,
      @_inheritActorContext @_implicitSelfCapture operation: (Self) async throws -> ReturnType
   ) async throws -> ReturnType {
      precondition(isIdempotent)

      return try await unsafeRetryIgnoringIdempotency(with: configuration,
                                                      operation: operation)
   }
}
