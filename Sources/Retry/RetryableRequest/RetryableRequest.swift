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

/// A protocol that adds safe retry methods to a conforming request type.
///
/// The retry methods in this protocol are similar to the top-level retry functions, but safer. The retry
/// methods in this protocol enforce that ``isIdempotent`` returns `true` since it is unsafe to
/// retry a non-idempotent request.
///
/// Conform request types to this protocol when ``isIdempotent`` can be implemented accurately.
/// For example, the HTTP specification defines certain HTTP request methods as idempotent, so it
/// would be straightforward to conform an HTTP request type to this protocol.
///
/// Conforming request types also need to implement
/// ``unsafeRetryIgnoringIdempotency(with:operation:)``. Implementations may choose
/// to override ``RetryConfiguration/shouldRetry`` to automatically handle errors specific to
/// the communication protocol.
public protocol RetryableRequest {
   /// Determines whether the request is idempotent.
   ///
   /// A request is considered idempotent if the intended effect on the server of multiple
   /// identical requests is the same as the effect for a single such request.
   var isIdempotent: Bool { get }

   /// Attempts the given operation until it succeeds or until the failure is no longer retryable.
   ///
   /// - Warning: This method is unsafe because it does not check ``isIdempotent``.
   ///    Consider using ``retry(with:operation:)`` instead.
   ///
   /// Failures may not be retryable for the following reasons:
   /// - The response indicates that the failure is not transient.
   /// - ``RetryConfiguration/shouldRetry`` returns `false`.
   /// - The thrown error is ``NotRetryable``.
   /// - The number of attempts reached ``RetryConfiguration/maxAttempts``.
   ///
   /// - Parameters:
   ///    - configuration: Configuration that specifies the behavior of this function.
   ///    - operation: Attempts the given request.
   ///
   /// - Note: The function will log messages using the `debug` log level to ``RetryConfiguration/logger``
   ///    (and/or ``RetryConfiguration/appleLogger`` on Apple platforms).
   func unsafeRetryIgnoringIdempotency<ClockType, ReturnType>(
      with configuration: RetryConfiguration<ClockType>,
      @_inheritActorContext @_implicitSelfCapture operation: (Self) async throws -> ReturnType
   ) async throws -> ReturnType
}
