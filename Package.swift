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
         name: "Retry",
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
