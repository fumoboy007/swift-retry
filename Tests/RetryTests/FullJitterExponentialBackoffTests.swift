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

@testable import Retry

import XCTest

final class FullJitterExponentialBackoffTests: XCTestCase {
   private let clock = ContinuousClock()

   // MARK: - Tests

   func testIsExponentialWithFullJitter() {
      let baseDelay = Duration.seconds(3)

      let randomNumberGeneratorFake = RandomNumberGeneratorFake(mode: .max)
      var algorithm = FullJitterExponentialBackoff(
         clock: clock,
         baseDelay: baseDelay,
         maxDelay: nil,
         randomNumberGenerator: randomNumberGeneratorFake
      )

      let delay1 = algorithm.nextDelay()
      assertEqualDelays(delay1, baseDelay)

      let delay2 = algorithm.nextDelay()
      assertEqualDelays(delay2, baseDelay * 2)

      let delay3 = algorithm.nextDelay()
      assertEqualDelays(delay3, baseDelay * 4)

      randomNumberGeneratorFake.mode = .min
      let delay4 = algorithm.nextDelay()
      assertEqualDelays(delay4, .zero)

      randomNumberGeneratorFake.mode = .max
      let delay5 = algorithm.nextDelay()
      assertEqualDelays(delay5, baseDelay * 16)
   }

   func testMaxDelay_normalValue() {
      let baseDelay = Duration.seconds(1)
      let maxDelay = Duration.seconds(3)

      var algorithm = FullJitterExponentialBackoff(
         clock: clock,
         baseDelay: baseDelay,
         maxDelay: maxDelay,
         randomNumberGenerator: RandomNumberGeneratorFake(mode: .max)
      )

      let delay1 = algorithm.nextDelay()
      assertEqualDelays(delay1, baseDelay)

      let delay2 = algorithm.nextDelay()
      assertEqualDelays(delay2, baseDelay * 2)

      let delay3 = algorithm.nextDelay()
      assertEqualDelays(delay3, maxDelay)

      let delay4 = algorithm.nextDelay()
      assertEqualDelays(delay4, maxDelay)
   }

   func testMaxDelay_extremeValue() {
      let maxDelay = Duration(secondsComponent: .max,
                              attosecondsComponent: 0)

      var algorithm = FullJitterExponentialBackoff(
         clock: clock,
         baseDelay: .seconds(1),
         maxDelay: maxDelay,
         randomNumberGenerator: RandomNumberGeneratorFake(mode: .max)
      )

      let (maxDelaySecondsComponent, maxDelayAttosecondsComponent) = maxDelay.components
      // Make sure the delay has increased to the max.
      for _ in 0..<(maxDelaySecondsComponent.bitWidth + maxDelayAttosecondsComponent.bitWidth) {
         _ = algorithm.nextDelay()
      }

      let delay1 = algorithm.nextDelay()
      XCTAssertLessThanOrEqual(delay1, maxDelay)

      let delay2 = algorithm.nextDelay()
      XCTAssertEqual(delay2, delay1)
   }

   func testMaxDelay_notSpecified_hasImplicitMaxDelay() {
      var algorithm = FullJitterExponentialBackoff(
         clock: clock,
         baseDelay: .seconds(1),
         maxDelay: nil,
         randomNumberGenerator: RandomNumberGeneratorFake(mode: .max)
      )

      let implicitMaxDelayInClockTicks = type(of: algorithm).implicitMaxDelayInClockTicks
      let implicitMaxDelay = clock.minimumResolution * implicitMaxDelayInClockTicks

      // Make sure the delay has increased to the max.
      for _ in 0..<implicitMaxDelayInClockTicks.bitWidth {
         _ = algorithm.nextDelay()
      }

      let delay1 = algorithm.nextDelay()
      XCTAssertEqual(delay1, implicitMaxDelay)

      let delay2 = algorithm.nextDelay()
      XCTAssertEqual(delay2, implicitMaxDelay)
   }

   // MARK: - Assertions

   private func assertEqualDelays(_ lhs: Duration, _ rhs: Duration) {
      let lhsNanoseconds = lhs / .nanoseconds(1)
      let rhsNanoseconds = rhs / .nanoseconds(1)
      let accuracyNanoseconds = clock.minimumResolution / .nanoseconds(1)

      XCTAssertEqual(lhsNanoseconds, rhsNanoseconds, accuracy: accuracyNanoseconds)
   }
}
