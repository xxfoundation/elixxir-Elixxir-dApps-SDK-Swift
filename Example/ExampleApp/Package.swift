// swift-tools-version: 5.6

import PackageDescription

let package = Package(
  name: "example-app",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(
      name: "AppFeature",
      targets: ["AppFeature"]
    ),
    .library(
      name: "LandingFeature",
      targets: ["LandingFeature"]
    ),
    .library(
      name: "SessionFeature",
      targets: ["SessionFeature"]
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
        .target(name: "LandingFeature"),
        .target(name: "SessionFeature"),
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
    .target(
      name: "LandingFeature",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
      ]
    ),
    .testTarget(
      name: "LandingFeatureTests",
      dependencies: [
        .target(name: "LandingFeature"),
      ]
    ),
    .target(
      name: "SessionFeature",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        ),
      ]
    ),
    .testTarget(
      name: "SessionFeatureTests",
      dependencies: [
        .target(name: "SessionFeature"),
      ]
    ),
  ]
)
