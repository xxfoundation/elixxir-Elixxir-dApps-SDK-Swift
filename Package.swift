// swift-tools-version: 5.6

import PackageDescription

let swiftSettings: [SwiftSetting] = [
  .unsafeFlags(
    [
      "-Xfrontend", "-debug-time-function-bodies",
      "-Xfrontend", "-debug-time-expression-type-checking",
    ],
    .when(configuration: .debug)
  ),
]

let package = Package(
  name: "elixxir-dapps-sdk-swift",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v14),
    .macOS(.v12),
  ],
  products: [
    .library(name: "XXClient", targets: ["XXClient"]),
    .library(name: "XXMessengerClient", targets: ["XXMessengerClient"]),
  ],
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-custom-dump.git",
      .upToNextMajor(from: "0.5.0")
    ),
    .package(
      url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git",
      .upToNextMajor(from: "0.4.0")
    ),
    .package(
      url: "https://github.com/kishikawakatsumi/KeychainAccess.git",
      .upToNextMajor(from: "4.2.2")
    ),
  ],
  targets: [
    .target(
      name: "XXClient",
      dependencies: [
        .target(name: "Bindings"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "XXClientTests",
      dependencies: [
        .target(name: "XXClient"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "XXMessengerClient",
      dependencies: [
        .target(name: "XXClient"),
        .product(name: "KeychainAccess", package: "KeychainAccess"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "XXMessengerClientTests",
      dependencies: [
        .target(name: "XXMessengerClient"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ],
      swiftSettings: swiftSettings
    ),
    .binaryTarget(
      name: "Bindings",
      path: "Frameworks/Bindings.xcframework"
    ),
  ]
)
