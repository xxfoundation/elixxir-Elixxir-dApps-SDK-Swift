// swift-tools-version: 5.6

import PackageDescription

let swiftSettings: [SwiftSetting] = [
  .unsafeFlags(
    [
      "-Xfrontend",
      "-debug-time-function-bodies",
      "-Xfrontend",
      "-debug-time-expression-type-checking",
    ],
    .when(configuration: .debug)
  ),
]

let package = Package(
  name: "elixxir-dapps-sdk-swift",
  defaultLocalization: "en",
  platforms: [
    .iOS(.v14),
  ],
  products: [
    .library(
      name: "ElixxirDAppsSDK",
      targets: ["ElixxirDAppsSDK"]
    ),
  ],
  targets: [
    .target(
      name: "ElixxirDAppsSDK",
      dependencies: [
        .target(name: "Bindings"),
      ],
      swiftSettings: swiftSettings
    ),
    .binaryTarget(
      name: "Bindings",
      path: "Frameworks/Bindings.xcframework"
    ),
  ]
)
