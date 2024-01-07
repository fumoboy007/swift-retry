// MIT License
//
// Copyright © 2024 Darren Mo.
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

/// The action to take after an attempt fails.
public enum RecoveryAction<ClockType: Clock> {
   /// Retries the operation, unless the number of attempts reached ``RetryConfiguration/maxAttempts``.
   case retry

   /// Retries the operation only after the given instant in time has been reached.
   ///
   /// For example, an HTTP server may send a `Retry-After` header in its response, which indicates
   /// to the client that the request should not be retried until after a minimum amount of time has passed.
   /// This recovery action can be used for such a use case.
   ///
   /// It is not guaranteed that the operation will be retried. The backoff process continues until the given
   /// instant in time has been reached, incrementing the number of attempts as usual. The operation will
   /// be retried only if the number of attempts has not reached ``RetryConfiguration/maxAttempts``.
   case retryAfter(ClockType.Instant)

   /// Throws the error without retrying the operation.
   case `throw`
}
