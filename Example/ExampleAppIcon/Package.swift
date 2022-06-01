// swift-tools-version: 5.6
import PackageDescription

let package = Package(
  name: "example-app-icon",
  platforms: [
    .macOS(.v12),
  ],
  products: [
    .library(
      name: "ExampleAppIcon",
      targets: ["ExampleAppIcon"]
    ),
    .executable(
      name: "example-app-icon-export",
      targets: ["ExampleAppIconExport"]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/darrarski/swiftui-app-icon-creator.git",
      .upToNextMajor(from: "1.2.0")
    ),
  ],
  targets: [
    .target(
      name: "ExampleAppIcon",
      dependencies: [
        .product(
          name: "AppIconCreator",
          package: "swiftui-app-icon-creator"
        ),
      ]
    ),
    .executableTarget(
      name: "ExampleAppIconExport",
      dependencies: [
        .target(name: "ExampleAppIcon"),
      ]
    )
  ]
)
