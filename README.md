# swift-retry

Retries in Swift with sensible defaults and powerful flexibility.

![Swift 5.9](https://img.shields.io/badge/swift-v5.9-%23F05138)
![Linux, visionOS 1, macOS 13, iOS 16, tvOS 16, watchOS 9](https://img.shields.io/badge/platform-Linux%20%7C%20visionOS%201%20%7C%20macOS%2013%20%7C%20iOS%2016%20%7C%20tvOS%2016%20%7C%20watchOS%209-blue)
![MIT License](https://img.shields.io/github/license/fumoboy007/swift-retry)
![Automated Tests Workflow Status](https://img.shields.io/github/actions/workflow/status/fumoboy007/swift-retry/tests.yml?event=push&label=tests)

## Features

- Designed for [Swift Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/).
- Sensible default retry behavior.
- Flexible enough for any use case.
- Comprehensive tests and documentation.

## Basic Usage

```swift
try await retry {
   try await doSomething()
}
```

See the [documentation](https://fumoboy007.github.io/swift-retry/documentation/retry/) for examples of more sophisticated use cases.
