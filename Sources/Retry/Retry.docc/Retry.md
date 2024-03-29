# ``Retry``

Retries with sensible defaults and powerful flexibility.

## Overview

### Designed for Swift Concurrency

The ``retry(maxAttempts:backoff:appleLogger:logger:operation:recoverFromFailure:)`` function is an `async` function that runs the given `async` closure repeatedly until it succeeds or until the failure is no longer retryable. The function sleeps in between attempts while respecting task cancellation.

### Sensible Defaults

The library uses similar defaults as [Amazon Web Services](https://docs.aws.amazon.com/sdkref/latest/guide/feature-retry-behavior.html) and [Google Cloud](https://github.com/googleapis/gax-go/blob/465d35f180e8dc8b01979d09c780a10c41f15136/v2/call_option.go#L181-L205).

An important but often overlooked default is the choice of backoff algorithm, which determines how long to sleep in between attempts. This library chooses an [exponential backoff](https://en.wikipedia.org/wiki/Exponential_backoff) algorithm by default, which is suitable for most use cases. Most retry use cases involve a resource, such as a server, with potentially many clients where an exponential backoff algorithm would be ideal to avoid [DDoSing the resource](https://cloud.google.com/blog/products/gcp/how-to-avoid-a-self-inflicted-ddos-attack-cre-life-lessons).

### Powerful Flexibility

The API provides several customization points to accommodate any use case:
- Retries can be selectively enabled or disabled for specific error cases by providing a custom ``RetryConfiguration/recoverFromFailure`` closure. Retries can also be selectively enabled or disabled for specific code paths by wrapping thrown errors with ``Retryable`` or ``NotRetryable``. 
- The ``RetryConfiguration`` type encapsulates the retry behavior so that it can be reused across multiple call sites without duplicating code.
- The ``Backoff`` type represents the choice of algorithm that will be used to determine how long to sleep in between attempts. It has built-in support for common algorithms but can be initialized with a custom ``BackoffAlgorithm`` implementation if needed.
- The ``RetryConfiguration/clock`` that is used to sleep in between attempts can be replaced. For example, one might use a fake `Clock` implementation in automated tests to ensure the tests are deterministic and efficient.

### Safe Retries

The module exposes a ``RetryableRequest`` protocol to add safe retry methods to a conforming request type. The retry methods in the protocol are similar to the top-level retry functions, but safer. The retry methods in the protocol enforce that the request is idempotent since it is unsafe to retry a non-idempotent request.

To retry HTTP requests, consider using the [`swift-http-error-handling`](https://swiftpackageindex.com/fumoboy007/swift-http-error-handling) package, which adds ``RetryableRequest`` conformance to the standard `HTTPRequest` type.

## Topics

### Examples

- <doc:Common-Use-Cases>
- <doc:Advanced-Use-Cases>

### Retrying Operations

- ``retry(maxAttempts:backoff:appleLogger:logger:operation:recoverFromFailure:)``
- ``retry(maxAttempts:clock:backoff:appleLogger:logger:operation:recoverFromFailure:)-6s251``
- ``retry(maxAttempts:clock:backoff:appleLogger:logger:operation:recoverFromFailure:)-2e9va``
- ``retry(with:operation:)``

### Configuring the Retry Behavior

- ``RetryConfiguration``
- ``RecoveryAction``
- ``Backoff``
- ``BackoffAlgorithm``

### Enabling/Disabling Retries for Specific Code Paths

- ``Retryable``
- ``NotRetryable``

### Safely Retrying Requests

- ``RetryableRequest``
