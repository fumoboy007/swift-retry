// swift-tools-version: 5.9

import PackageDescription

let package = Package(
   name: "swift-retry",
   platforms: [
      .visionOS(.v1),
      .macOS(.v13),
      .macCatalyst(.v16),
      .iOS(.v16),
      .tvOS(.v16),
      .watchOS(.v9),
   ],
   products: [
      .library(
         // TODO: Remove `DM` prefix after FB13180164 is resolved. The Xcode build system fails to build
         // a package graph that has duplicate product names. Other retry packages may also name their
         // library `Retry`, so we add a prefix to distinguish this package’s library.
         name: "DMRetry",
         targets: [
            "Retry",
         ]
      ),
   ],
   dependencies: [
      .package(url: "https://github.com/apple/swift-docc-plugin.git", from: "1.3.0"),
      .package(url: "https://github.com/apple/swift-log.git", from: "1.5.3"),
   ],
   targets: [
      .target(
         name: "Retry",
         dependencies: [
            .product(name: "Logging", package: "swift-log"),
         ]
      ),
      .testTarget(
         name: "RetryTests",
         dependencies: [
            "Retry",
         ]
      ),
   ]
)
