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

import Logging

extension Logger {
   /// The metadata keys used by the retry implementation.
   public enum RetryMetadataKey: String {
      /// The zero-based attempt number.
      case attemptNumber = "retry.attempt"

      /// The Swift type of the error that caused the attempt to fail.
      ///
      /// This is the original error after removing wrapper types like ``Retryable`` and ``NotRetryable``.
      case errorType = "retry.error.type"

      /// The delay before the next attempt.
      ///
      /// The metadata value format is an implementation detail of the Swift standard library, so it may change
      /// when the Swift version changes.
      case retryDelay = "retry.delay"

      /// The minimum delay before the next attempt, as requested via ``RecoveryAction/retryAfter(_:)``.
      ///
      /// The metadata value format is an implementation detail of the Swift standard library, so it may change
      /// when the Swift version changes.
      case requestedMinRetryDelay = "retry.after"
   }
}

extension Logger {
   subscript(metadataKey metadataKey: RetryMetadataKey) -> Metadata.Value? {
      get {
         return self[metadataKey: metadataKey.rawValue]
      }

      set {
         self[metadataKey: metadataKey.rawValue] = newValue
      }
   }
}

extension Logger {
   func trace(_ message: @autoclosure () -> Logger.Message,
              metadata: @autoclosure () -> [RetryMetadataKey: MetadataValue]? = nil,
              source: @autoclosure () -> String? = nil,
              file: String = #fileID,
              function: String = #function,
              line: UInt = #line) {
      log(level: .trace,
          message(),
          metadata: metadata(),
          source: source(),
          file: file,
          function: function,
          line: line)
   }

   func debug(_ message: @autoclosure () -> Logger.Message,
              metadata: @autoclosure () -> [RetryMetadataKey: MetadataValue]? = nil,
              source: @autoclosure () -> String? = nil,
              file: String = #fileID,
              function: String = #function,
              line: UInt = #line) {
      log(level: .debug,
          message(),
          metadata: metadata(),
          source: source(),
          file: file,
          function: function,
          line: line)
   }

   func info(_ message: @autoclosure () -> Logger.Message,
             metadata: @autoclosure () -> [RetryMetadataKey: MetadataValue]? = nil,
             source: @autoclosure () -> String? = nil,
             file: String = #fileID,
             function: String = #function,
             line: UInt = #line) {
      log(level: .info,
          message(),
          metadata: metadata(),
          source: source(),
          file: file,
          function: function,
          line: line)
   }

   func notice(_ message: @autoclosure () -> Logger.Message,
               metadata: @autoclosure () -> [RetryMetadataKey: MetadataValue]? = nil,
               source: @autoclosure () -> String? = nil,
               file: String = #fileID,
               function: String = #function,
               line: UInt = #line) {
      log(level: .notice,
          message(),
          metadata: metadata(),
          source: source(),
          file: file,
          function: function,
          line: line)
   }

   func warning(_ message: @autoclosure () -> Logger.Message,
                metadata: @autoclosure () -> [RetryMetadataKey: MetadataValue]? = nil,
                source: @autoclosure () -> String? = nil,
                file: String = #fileID,
                function: String = #function,
                line: UInt = #line) {
      log(level: .warning,
          message(),
          metadata: metadata(),
          source: source(),
          file: file,
          function: function,
          line: line)
   }

   func error(_ message: @autoclosure () -> Logger.Message,
              metadata: @autoclosure () -> [RetryMetadataKey: MetadataValue]? = nil,
              source: @autoclosure () -> String? = nil,
              file: String = #fileID,
              function: String = #function,
              line: UInt = #line) {
      log(level: .error,
          message(),
          metadata: metadata(),
          source: source(),
          file: file,
          function: function,
          line: line)
   }

   func critical(_ message: @autoclosure () -> Logger.Message,
                 metadata: @autoclosure () -> [RetryMetadataKey: MetadataValue]? = nil,
                 source: @autoclosure () -> String? = nil,
                 file: String = #fileID,
                 function: String = #function,
                 line: UInt = #line) {
      log(level: .critical,
          message(),
          metadata: metadata(),
          source: source(),
          file: file,
          function: function,
          line: line)
   }

   func log(level: Level,
            _ message: @autoclosure () -> Message,
            metadata: @autoclosure () -> [RetryMetadataKey: MetadataValue]? = nil,
            source: @autoclosure () -> String? = nil,
            file: String = #fileID,
            function: String = #function,
            line: UInt = #line) {
      log(level: level,
          message(),
          metadata: Self.transform(metadata()),
          source: source(),
          file: file,
          function: function,
          line: line)
   }

   private static func transform(_ metadata: [RetryMetadataKey: MetadataValue]?) -> Metadata? {
      guard let metadata else {
         return nil
      }

      return Dictionary(uniqueKeysWithValues: metadata.lazy.map { ($0.key.rawValue, $0.value) })
   }
}
