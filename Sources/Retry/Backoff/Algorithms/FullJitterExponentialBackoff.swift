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

struct FullJitterExponentialBackoff<ClockType, RandomNumberGeneratorType>: BackoffAlgorithm
where ClockType: Clock, RandomNumberGeneratorType: RandomNumberGenerator {
   static var implicitMaxDelayInClockTicks: Int {
      return Int.max
   }

   private let clockMinResolution: ClockType.Duration

   private let baseDelayInClockTicks: Double
   private let maxDelayInClockTicks: Double

   private let maxExponent: Int

   private var randomNumberGenerator: RandomNumberGeneratorType

   private var attempt = 0

   init(clock: ClockType,
        baseDelay: ClockType.Duration,
        maxDelay: ClockType.Duration?,
        randomNumberGenerator: RandomNumberGeneratorType) {
      self.clockMinResolution = clock.minimumResolution

      self.baseDelayInClockTicks = baseDelay / clockMinResolution
      precondition(baseDelayInClockTicks > 0, "The base delay must be greater than zero.")

      if let maxDelay {
         precondition(maxDelay >= baseDelay, "The max delay must be greater than or equal to the base delay.")
         self.maxDelayInClockTicks = min(maxDelay / clockMinResolution,
                                         Double(Self.implicitMaxDelayInClockTicks))
      } else {
         self.maxDelayInClockTicks = Double(Self.implicitMaxDelayInClockTicks)
      }

      self.maxExponent = Self.closestBaseTwoExponentOfValue(greaterThanOrEqualTo: Int((maxDelayInClockTicks / baseDelayInClockTicks).rounded(.up)))

      self.randomNumberGenerator = randomNumberGenerator
   }

   private static func closestBaseTwoExponentOfValue(greaterThanOrEqualTo value: Int) -> Int {
      precondition(value >= 0)

      if value.nonzeroBitCount == 1 {
         return Int.bitWidth - value.leadingZeroBitCount - 1
      } else {
         return min(Int.bitWidth - value.leadingZeroBitCount, Int.bitWidth - 1)
      }
   }

   mutating func nextDelay() -> ClockType.Duration {
      defer {
         attempt += 1
      }

      // Limit the exponent to prevent the bit shift operation from overflowing.
      let exponent = min(attempt, maxExponent)
      let maxDelayInClockTicks = min(baseDelayInClockTicks * Double(1 << exponent),
                                     maxDelayInClockTicks)

      let delayInClockTicks = randomNumberGenerator.random(in: 0...maxDelayInClockTicks)

      // Unfortunately, `DurationProtocol` does not have a `Duration * Double` operator, so we need to cast to `Int`.
      // We make sure to cast to `Int` at the end rather than at the beginning so that the imprecision is bounded.
      return clockMinResolution * Int(clamping: UInt(delayInClockTicks.rounded()))
   }
}

extension FullJitterExponentialBackoff where RandomNumberGeneratorType == StandardRandomNumberGenerator {
   init(clock: ClockType,
        baseDelay: ClockType.Duration,
        maxDelay: ClockType.Duration?) {
      self.init(clock: clock,
                baseDelay: baseDelay,
                maxDelay: maxDelay,
                randomNumberGenerator: StandardRandomNumberGenerator())
   }
}
