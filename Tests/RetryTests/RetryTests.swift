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
         shouldRetry: { _ in true }
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
      try await assertThrowsErrorFake {
         try await retry(with: testingConfiguration) {
            throw ErrorFake()
         }
      }

      assertRetried(times: Self.maxAttempts - 1)
   }

   func testFailure_shouldRetryReturnsFalse_failureWithoutRetry() async throws {
      precondition(Self.maxAttempts > 1)

      try await assertThrowsErrorFake {
         try await retry(with: testingConfiguration.withShouldRetry({ _ in false })) {
            throw ErrorFake()
         }
      }

      assertRetried(times: 0)
   }

   func testFailure_isNotRetryableError_failureWithoutRetry() async throws {
      precondition(Self.maxAttempts > 1)

      try await assertThrowsErrorFake {
         try await retry(with: testingConfiguration) {
            throw NotRetryable(ErrorFake())
         }
      }

      assertRetried(times: 0)
   }

   func testOneFailure_isRetryableError_successAfterRetry() async throws {
      precondition(Self.maxAttempts > 1)

      var isFirstAttempt = true

      try await retry(with: testingConfiguration.withShouldRetry({ _ in false })) {
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
      try await assertThrowsErrorFake {
         try await retry(with: testingConfiguration) {
            throw Retryable(NotRetryable(ErrorFake()))
         }
      }

      assertRetried(times: Self.maxAttempts - 1)
   }

   func testFailure_errorIsNotRetryableError_throwsOriginalError() async throws {
      try await assertThrowsErrorFake {
         try await retry(with: testingConfiguration) {
            throw NotRetryable(Retryable(ErrorFake()))
         }
      }

      assertRetried(times: 0)
   }

   // MARK: - Assertions

   private func assertThrowsErrorFake(operation: () async throws -> Void) async throws {
      do {
         try await operation()
      } catch is ErrorFake {
         // Expected.
      }
   }

   private func assertRetried(times retryCount: Int) {
      XCTAssertEqual(clockFake.allSleepDurations,
                     BackoffAlgorithmFake.delays(ofCount: retryCount, for: clockFake))
   }
}
