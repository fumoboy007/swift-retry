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

/// The choice of algorithm that will be used to determine how long to sleep in between attempts.
public struct Backoff<ClockType: Clock> {
   // MARK: - Built-In Algorithms

   /// The default algorithm, which is suitable for most use cases.
   ///
   /// This algorithm is an [exponential backoff](https://en.wikipedia.org/wiki/Exponential_backoff) algorithm.
   /// The specific choice of algorithm is an implementation detail, which may change in the future.
   ///
   /// - Parameters:
   ///    - baseDelay: A duration that all delays will be based on. For example, in a simple exponential
   ///       backoff algorithm, the first delay might be `baseDelay`, the second delay might be
   ///       `baseDelay * 2`, the third delay  might be `baseDelay * 2 * 2`, and so on.
   ///    - maxDelay: The desired maximum duration in between attempts. There may also be a maximum
   ///       enforced by the algorithm implementation.
   public static func `default`(baseDelay: ClockType.Duration,
                                maxDelay: ClockType.Duration?) -> Self {
      return exponentialWithFullJitter(baseDelay: baseDelay,
                                       maxDelay: maxDelay)
   }

   /// Exponential backoff with “full jitter”.
   ///
   /// This algorithm is used by [AWS](https://docs.aws.amazon.com/sdkref/latest/guide/feature-retry-behavior.html) and
   /// [Google Cloud](https://github.com/googleapis/gax-go/blob/465d35f180e8dc8b01979d09c780a10c41f15136/v2/call_option.go#L181-L205),
   /// among others. The advantages and disadvantages of the algorithm are detailed in a [blog post](https://aws.amazon.com/blogs/architecture/exponential-backoff-and-jitter/)
   /// by AWS.
   ///
   /// - Parameters:
   ///    - baseDelay: A duration that all delays will be based on. For example, in a simple exponential
   ///       backoff algorithm, the first delay might be `baseDelay`, the second delay might be
   ///       `baseDelay * 2`, the third delay  might be `baseDelay * 2 * 2`, and so on.
   ///    - maxDelay: The desired maximum duration in between attempts. There may also be a maximum
   ///       enforced by the algorithm implementation.
   ///
   /// - SeeAlso: ``default(baseDelay:maxDelay:)``
   public static func exponentialWithFullJitter(baseDelay: ClockType.Duration,
                                                maxDelay: ClockType.Duration?) -> Self {
      return Self { clock in
         return FullJitterExponentialBackoff(clock: clock,
                                             baseDelay: baseDelay,
                                             maxDelay: maxDelay)
      }
   }

   /// Constant delay.
   ///
   /// - Warning: This algorithm should only be used as an optimization for a small set of use cases.
   ///    Most retry use cases involve a resource, such as a server, with potentially many clients where an
   ///    exponential backoff algorithm would be ideal to avoid [DDoSing the resource](https://cloud.google.com/blog/products/gcp/how-to-avoid-a-self-inflicted-ddos-attack-cre-life-lessons).
   ///    The constant delay algorithm should only be used in cases where there is no possibility of a DDoS.
   ///
   /// - Parameter delay: The constant duration to sleep in between attempts.
   ///
   /// - SeeAlso: ``default(baseDelay:maxDelay:)``
   public static func constant(_ delay: ClockType.Duration) -> Self {
      return Self { _ in
         return ConstantBackoff<ClockType>(delay: delay)
      }
   }

   // MARK: - Private Properties

   private let makeAlgorithmClosure: @Sendable (ClockType) -> any BackoffAlgorithm

   // MARK: - Initialization

   /// Initializes the instance with a specific algorithm.
   ///
   /// - Parameter makeAlgorithm: A closure that returns a ``BackoffAlgorithm`` implementation.
   ///
   /// - SeeAlso: ``default(baseDelay:maxDelay:)``
   public init(makeAlgorithm: @escaping @Sendable (ClockType) -> any BackoffAlgorithm) {
      self.makeAlgorithmClosure = makeAlgorithm
   }

   // MARK: - Making the Algorithm

   func makeAlgorithm(clock: ClockType) -> any BackoffAlgorithm {
      return makeAlgorithmClosure(clock)
   }
}

extension Backoff: Sendable {
}
