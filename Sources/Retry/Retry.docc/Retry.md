# ``Retry``

Retries with sensible defaults and powerful flexibility.

## Overview

- Designed for [Swift Concurrency](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/concurrency/).
- Sensible default retry behavior.
- Flexible enough for any use case.

## Topics

### Examples

- <doc:Common-Use-Cases>
- <doc:Advanced-Use-Cases>

### Retrying Operations

- ``retry(maxAttempts:backoff:appleLogger:logger:operation:shouldRetry:)``
- ``retry(maxAttempts:clock:backoff:appleLogger:logger:operation:shouldRetry:)-2cjan``
- ``retry(maxAttempts:clock:backoff:appleLogger:logger:operation:shouldRetry:)-2aiqm``
- ``retry(with:operation:)``

### Configuring the Retry Behavior

- ``RetryConfiguration``
- ``Backoff``
- ``BackoffAlgorithm``

### Enabling/Disabling Retries for Specific Code Paths

- ``Retryable``
- ``NotRetryable``
