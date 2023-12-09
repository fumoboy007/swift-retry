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

import Foundation

class ClockFake: Clock, @unchecked Sendable {
   typealias Instant = ContinuousClock.Instant

   private let realClock = ContinuousClock()

   private let lock = NSLock()

   private var _now: Instant

   private var _allSleepDurations = [Duration]()

   init() {
      self._now = realClock.now
   }

   var now: Instant {
      lock.lock()
      defer {
         lock.unlock()
      }

      return _now
   }

   var minimumResolution: Duration {
      return realClock.minimumResolution
   }

   func sleep(until deadline: Instant,
              tolerance: Duration?) async throws {
      // Refactored into a non-async method so that `NSLock.lock` and `NSLock.unlock` can be used.
      // Cannot use the async-safe `NSLock.withLocking` method until the following change is released:
      // https://github.com/apple/swift-corelibs-foundation/pull/4736
      sleep(until: deadline)
   }

   private func sleep(until deadline: Instant) {
      lock.lock()
      defer {
         lock.unlock()
      }

      let duration = deadline - _now
      _allSleepDurations.append(duration)

      _now = max(deadline, _now)
   }

   var allSleepDurations: [Duration] {
      lock.lock()
      defer {
         lock.unlock()
      }

      return _allSleepDurations
   }
}
