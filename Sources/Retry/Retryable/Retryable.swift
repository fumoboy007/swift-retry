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

/// A concrete error type that is always retryable and wraps an underlying error.
///
/// Throwing this error will always result in a retry, unless there are other conditions that make the failure
/// not retryable like reaching the maximum number of attempts.
///
/// This wrapper type exists for the cases where ``RetryConfiguration/shouldRetry`` cannot make
/// a good decision (e.g. the underlying error type is not exposed by a library dependency).
public struct Retryable: Error {
   let underlyingError: any Error

   /// Wraps the given error.
   ///
   /// - Parameter underlyingError: The error being wrapped. This will be the actual error thrown
   ///    if the failure is no longer retryable.
   public init(_ underlyingError: any Error) {
      self.underlyingError = underlyingError
   }
}
