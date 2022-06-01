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
  ],
  targets: [
    .target(
      name: "AppFeature",
      dependencies: [
        .product(
          name: "ElixxirDAppsSDK",
          package: "elixxir-dapps-sdk-swift"
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
