// swift-tools-version: 5.6
import PackageDescription

let swiftSettings: [SwiftSetting] = [
  .unsafeFlags(
    [
      // "-Xfrontend", "-warn-concurrency",
      "-Xfrontend", "-debug-time-function-bodies",
      "-Xfrontend", "-debug-time-expression-type-checking",
    ],
    .when(configuration: .debug)
  ),
]

let package = Package(
  name: "xx-messenger",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(name: "AppCore", targets: ["AppCore"]),
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "ContactFeature", targets: ["ContactFeature"]),
    .library(name: "HomeFeature", targets: ["HomeFeature"]),
    .library(name: "RegisterFeature", targets: ["RegisterFeature"]),
    .library(name: "RestoreFeature", targets: ["RestoreFeature"]),
    .library(name: "UserSearchFeature", targets: ["UserSearchFeature"]),
    .library(name: "WelcomeFeature", targets: ["WelcomeFeature"]),
  ],
  dependencies: [
    .package(
      path: "../../"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture.git",
      .upToNextMajor(from: "0.39.0")
    ),
    .package(
      url: "https://git.xx.network/elixxir/client-ios-db.git",
      .upToNextMajor(from: "1.1.0")
    ),
    .package(
      url: "https://github.com/darrarski/swift-composable-presentation.git",
      .upToNextMajor(from: "0.5.2")
    ),
    .package(
      url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git",
      .upToNextMajor(from: "0.4.0")
    ),
  ],
  targets: [
    .target(
      name: "AppCore",
      dependencies: [
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXDatabase", package: "client-ios-db"),
        .product(name: "XXModels", package: "client-ios-db"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "AppCoreTests",
      dependencies: [
        .target(name: "AppCore")
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "AppFeature",
      dependencies: [
        .target(name: "AppCore"),
        .target(name: "ContactFeature"),
        .target(name: "HomeFeature"),
        .target(name: "RegisterFeature"),
        .target(name: "RestoreFeature"),
        .target(name: "UserSearchFeature"),
        .target(name: "WelcomeFeature"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXModels", package: "client-ios-db"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "AppFeatureTests",
      dependencies: [
        .target(name: "AppFeature"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "ContactFeature",
      dependencies: [
        .target(name: "AppCore"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXModels", package: "client-ios-db"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "ContactFeatureTests",
      dependencies: [
        .target(name: "ContactFeature"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "HomeFeature",
      dependencies: [
        .target(name: "AppCore"),
        .target(name: "RegisterFeature"),
        .target(name: "UserSearchFeature"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "HomeFeatureTests",
      dependencies: [
        .target(name: "HomeFeature"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "RegisterFeature",
      dependencies: [
        .target(name: "AppCore"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXModels", package: "client-ios-db"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "RegisterFeatureTests",
      dependencies: [
        .target(name: "RegisterFeature"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "RestoreFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "RestoreFeatureTests",
      dependencies: [
        .target(name: "RestoreFeature"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "UserSearchFeature",
      dependencies: [
        .target(name: "ContactFeature"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXModels", package: "client-ios-db"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "UserSearchFeatureTests",
      dependencies: [
        .target(name: "UserSearchFeature"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "WelcomeFeature",
      dependencies: [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "WelcomeFeatureTests",
      dependencies: [
        .target(name: "WelcomeFeature"),
      ],
      swiftSettings: swiftSettings
    ),
  ]
)
