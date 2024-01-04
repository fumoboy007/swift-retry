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

import Retry

import XCTest

final class RetryTests: XCTestCase {
   private static let maxAttempts = 2

   private var clockFake: ClockFake!
   private var testingConfiguration: RetryConfiguration<ClockFake>!

   override func setUp() {
      super.setUp()

      clockFake = ClockFake()
      testingConfiguration = RetryConfiguration(
         maxAttempts: Self.maxAttempts,
         clock: clockFake,
         backoff: Backoff { BackoffAlgorithmFake(clock: $0) },
         recoverFromFailure: { _ in .retry }
      )
   }

   override func tearDown() {
      clockFake = nil
      testingConfiguration = nil

      super.tearDown()
   }

   // MARK: - Tests

   func testNoFailure_successWithoutRetry() async throws {
      try await retry(with: testingConfiguration) {
         // Success.
      }

      assertRetried(times: 0)
   }

   func testOneFailure_successAfterRetry() async throws {
      precondition(Self.maxAttempts > 1)

      var isFirstAttempt = true

      try await retry(with: testingConfiguration) {
         if isFirstAttempt {
            isFirstAttempt = false

            throw ErrorFake()
         } else {
            // Success.
         }
      }

      assertRetried(times: 1)
   }

   func testAllAttemptsFail_failureAfterRetries() async throws {
      try await assertThrows(ErrorFake.self) {
         try await retry(with: testingConfiguration) {
            throw ErrorFake()
         }
      }

      assertRetried(times: Self.maxAttempts - 1)
   }

   func testFailure_recoverFromFailureDecidesToThrow_failureWithoutRetry() async throws {
      precondition(Self.maxAttempts > 1)

      try await assertThrows(ErrorFake.self) {
         try await retry(with: testingConfiguration.withRecoverFromFailure({ _ in .throw })) {
            throw ErrorFake()
         }
      }

      assertRetried(times: 0)
   }

   func testFailure_isNotRetryableError_recoverFromFailureNotCalled_failureWithoutRetry() async throws {
      precondition(Self.maxAttempts > 1)

      let configuration = testingConfiguration.withRecoverFromFailure { error in
         XCTFail("`recoverFromFailure` should not be called when the error is `NotRetryable`.")
         return .retry
      }

      try await assertThrows(ErrorFake.self) {
         try await retry(with: configuration) {
            throw NotRetryable(ErrorFake())
         }
      }

      assertRetried(times: 0)
   }

   func testOneFailure_isRetryableError_recoverFromFailureNotCalled_successAfterRetry() async throws {
      precondition(Self.maxAttempts > 1)

      let configuration = testingConfiguration.withRecoverFromFailure { error in
         XCTFail("`recoverFromFailure` should not be called when the error is `Retryable`.")
         return .throw
      }

      var isFirstAttempt = true

      try await retry(with: configuration) {
         if isFirstAttempt {
            isFirstAttempt = false

            throw Retryable(ErrorFake())
         } else {
            // Success.
         }
      }

      assertRetried(times: 1)
   }

   func testAllAttemptsFail_latestErrorIsRetryableError_throwsOriginalError() async throws {
      try await assertThrows(ErrorFake.self) {
         try await retry(with: testingConfiguration) {
            throw Retryable(NotRetryable(ErrorFake()))
         }
      }

      assertRetried(times: Self.maxAttempts - 1)
   }

   func testFailure_isNotRetryableError_throwsOriginalError() async throws {
      try await assertThrows(ErrorFake.self) {
         try await retry(with: testingConfiguration) {
            throw NotRetryable(Retryable(ErrorFake()))
         }
      }

      assertRetried(times: 0)
   }

   func testFailure_isCancellationError_recoverFromFailureNotCalled_failureWithoutRetry() async throws {
      precondition(Self.maxAttempts > 1)

      let configuration = testingConfiguration.withRecoverFromFailure { error in
         XCTFail("`recoverFromFailure` should not be called when the error is `CancellationError`.")
         return .retry
      }

      try await assertThrows(CancellationError.self) {
         try await retry(with: configuration) {
            throw CancellationError()
         }
      }

      assertRetried(times: 0)
   }

   func testFailure_isCancellationErrorWrappedInRetryableError_failureWithoutRetry() async throws {
      precondition(Self.maxAttempts > 1)

      try await assertThrows(CancellationError.self) {
         try await retry(with: testingConfiguration) {
            throw Retryable(CancellationError())
         }
      }

      assertRetried(times: 0)
   }

   func testFailure_isCancellationErrorWrappedInNotRetryableError_failureWithoutRetry() async throws {
      precondition(Self.maxAttempts > 1)

      try await assertThrows(CancellationError.self) {
         try await retry(with: testingConfiguration) {
            throw NotRetryable(CancellationError())
         }
      }

      assertRetried(times: 0)
   }

   func testCancelledDuringSleep_immediateFailure() async throws {
      precondition(Self.maxAttempts > 1)

      clockFake.isSleepEnabled = true
      let configuration = testingConfiguration.withBackoff(.constant(.seconds(60)))

      let retryTask = Task {
         try await retry(with: configuration) {
            throw ErrorFake()
         }
      }

      // Wait until the retry task is sleeping after the first attempt.
      while clockFake.allSleepDurations.isEmpty {
         try await Task.sleep(for: .milliseconds(1))
      }

      retryTask.cancel()

      let realClock = ContinuousClock()
      let start = realClock.now

      try await assertThrows(CancellationError.self) {
         try await retryTask.value
      }

      let end = realClock.now
      let duration = end - start
      XCTAssertLessThan(duration, .seconds(1))
   }

   // MARK: - Assertions

   private func assertThrows<T: Error>(
      _ errorType: T.Type,
      operation: () async throws -> Void
   ) async throws {
      do {
         try await operation()
      } catch is T {
         // Expected.
      }
   }

   private func assertRetried(times retryCount: Int) {
      XCTAssertEqual(clockFake.allSleepDurations,
                     BackoffAlgorithmFake.delays(ofCount: retryCount, for: clockFake))
   }
}
