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
// FB13460778: `Logger` does not currently conform to `Sendable` even though it is
// likely already concurrency-safe.
@preconcurrency import OSLog
#endif

/// Configures the retry behavior.
public struct RetryConfiguration<ClockType: Clock> {
   /// The maximum number of times to attempt the operation.
   ///
   /// - Precondition: Must be greater than `0`.
   public var maxAttempts: Int?

   /// The clock that will be used to sleep in between attempts.
   public var clock: ClockType
   /// The algorithm that determines how long to wait in between attempts.
   public var backoff: Backoff<ClockType>

#if canImport(OSLog)
   /// The logger that will be used to log a message when an attempt fails.
   public var appleLogger: os.Logger?
#endif
   /// The logger that will be used to log a message when an attempt fails.
   ///
   /// - Remark: On Apple platforms, consider using ``appleLogger`` for potentially more
   ///    detailed log messages and better integration with the logging system.
   public var logger: Logging.Logger?

   /// A closure that determines whether to retry, given the error that was thrown.
   ///
   /// - Note: The closure will not be called if the error is ``Retryable`` or ``NotRetryable``.
   public var shouldRetry: @Sendable (any Error) -> Bool

   public init(maxAttempts: Int?,
               clock: ClockType,
               backoff: Backoff<ClockType>,
               shouldRetry: @escaping @Sendable (any Error) -> Bool) {
      if let maxAttempts {
         precondition(maxAttempts > 0)
      }

      self.maxAttempts = maxAttempts

      self.clock = clock
      self.backoff = backoff

      self.shouldRetry = shouldRetry
   }

   public func withMaxAttempts(_ newValue: Int?) -> Self {
      var newConfiguration = self
      newConfiguration.maxAttempts = newValue
      return newConfiguration
   }

   public func withClock(_ newValue: ClockType) -> Self {
      var newConfiguration = self
      newConfiguration.clock = newValue
      return newConfiguration
   }

   public func withBackoff(_ newValue: Backoff<ClockType>) -> Self {
      var newConfiguration = self
      newConfiguration.backoff = newValue
      return newConfiguration
   }

#if canImport(OSLog)
   public func withAppleLogger(_ newValue: os.Logger?) -> Self {
      var newConfiguration = self
      newConfiguration.appleLogger = newValue
      return newConfiguration
   }
#endif

   public func withLogger(_ newValue: Logging.Logger?) -> Self {
      var newConfiguration = self
      newConfiguration.logger = newValue
      return newConfiguration
   }

   public func withShouldRetry(_ newValue: @escaping @Sendable (any Error) -> Bool) -> Self {
      var newConfiguration = self
      newConfiguration.shouldRetry = newValue
      return newConfiguration
   }
}

extension RetryConfiguration: Sendable {
}

extension RetryConfiguration {
   public init(
      maxAttempts: Int?,
      backoff: Backoff<ClockType>,
      shouldRetry: @escaping @Sendable (any Error) -> Bool
   ) where ClockType == ContinuousClock {
      self.init(maxAttempts: maxAttempts,
                clock: ContinuousClock(),
                backoff: backoff,
                shouldRetry: shouldRetry)
   }

   public init(
      maxAttempts: Int?,
      backoff: Backoff<ClockType>,
      shouldRetry: @escaping @Sendable (any Error) -> Bool
   ) where ClockType == SuspendingClock {
      self.init(maxAttempts: maxAttempts,
                clock: SuspendingClock(),
                backoff: backoff,
                shouldRetry: shouldRetry)
   }
}
