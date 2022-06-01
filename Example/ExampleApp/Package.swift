// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "ExampleApp",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(
      name: "AppFeature",
      targets: ["AppFeature"]
    ),
  ],
  dependencies: [
    .package(path: "../../"), // elixxir-dapps-sdk-swift
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture.git",
      .upToNextMajor(from: "0.35.0")
    ),
    .package(
      url: "https://github.com/darrarski/swift-composable-presentation.git",
      .upToNextMajor(from: "0.5.2")
    ),
  ],
  targets: [
    .target(
      name: "AppFeature",
      dependencies: [
        .product(
          name: "ElixxirDAppsSDK",
          package: "elixxir-dapps-sdk-swift"
        ),
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
        .product(
          name: "ComposablePresentation",
          package: "swift-composable-presentation"
        ),
      ]
    ),
    .testTarget(
      name: "AppFeatureTests",
      dependencies: [
        .target(name: "AppFeature"),
      ]
    ),
  ]
)
