// swift-tools-version: 5.6
import PackageDescription

// MARK: - Helpers

struct Feature {
  var product: Product
  var targets: [Target]
  var targetDependency: Target.Dependency

  static func library(
    name: String,
    dependencies: [Target.Dependency] = [],
    testDependencies: [Target.Dependency] = [],
    swiftSettings: [SwiftSetting] = [
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
  ) -> Feature {
    .init(
      product: .library(name: name, targets: [name]),
      targets: [
        .target(
          name: name,
          dependencies: dependencies,
          swiftSettings: swiftSettings
        ),
        .testTarget(
          name: "\(name)Tests",
          dependencies: [.target(name: name)] + testDependencies,
          swiftSettings: swiftSettings
        ),
      ],
      targetDependency: .target(name: name)
    )
  }
}

struct Dependency {
  var packageDependency: Package.Dependency
  var targetDependency: Target.Dependency

  static func local(
    path: String,
    name: String,
    package: String
  ) -> Dependency {
    .init(
      packageDependency: .package(path: path),
      targetDependency: .product(name: name, package: package)
    )
  }

  static func external(
    url: String,
    version: Range<Version>,
    name: String,
    package: String
  ) -> Dependency {
    .init(
      packageDependency: .package(url: url, version),
      targetDependency: .product(name: name, package: package)
    )
  }
}

// MARK: - Manifest

extension Dependency {
  static let all: [Dependency] = [
    .composableArchitecture,
    .composablePresentation,
    .elixxirDAppsSDK,
    .keychainAccess,
    .xcTestDynamicOverlay,
  ]

  static let composableArchitecture = Dependency.external(
    url: "https://github.com/pointfreeco/swift-composable-architecture.git",
    version: .upToNextMajor(from: "0.38.3"),
    name: "ComposableArchitecture",
    package: "swift-composable-architecture"
  )

  static let composablePresentation = Dependency.external(
    url: "https://github.com/darrarski/swift-composable-presentation.git",
    version: .upToNextMajor(from: "0.5.2"),
    name: "ComposablePresentation",
    package: "swift-composable-presentation"
  )

  static let elixxirDAppsSDK = Dependency.local(
    path: "../../",
    name: "ElixxirDAppsSDK",
    package: "elixxir-dapps-sdk-swift"
  )

  static let keychainAccess = Dependency.external(
    url: "https://github.com/kishikawakatsumi/KeychainAccess.git",
    version: .upToNextMajor(from: "4.2.2"),
    name: "KeychainAccess",
    package: "KeychainAccess"
  )

  static let xcTestDynamicOverlay = Dependency.external(
    url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git",
    version: .upToNextMajor(from: "0.3.3"),
    name: "XCTestDynamicOverlay",
    package: "xctest-dynamic-overlay"
  )
}

extension Feature {
  static let all: [Feature] = [
    .app,
    .error,
    .landing,
    .session,
  ]

  static let app = Feature.library(
    name: "AppFeature",
    dependencies: [
      Feature.error.targetDependency,
      Feature.landing.targetDependency,
      Feature.session.targetDependency,
      Dependency.composableArchitecture.targetDependency,
      Dependency.composablePresentation.targetDependency,
      Dependency.elixxirDAppsSDK.targetDependency,
      Dependency.keychainAccess.targetDependency,
      Dependency.xcTestDynamicOverlay.targetDependency,
    ]
  )

  static let error = Feature.library(
    name: "ErrorFeature",
    dependencies: [
      Dependency.composableArchitecture.targetDependency,
      Dependency.elixxirDAppsSDK.targetDependency,
      Dependency.xcTestDynamicOverlay.targetDependency,
    ]
  )

  static let landing = Feature.library(
    name: "LandingFeature",
    dependencies: [
      Feature.error.targetDependency,
      Dependency.composableArchitecture.targetDependency,
      Dependency.composablePresentation.targetDependency,
      Dependency.elixxirDAppsSDK.targetDependency,
      Dependency.xcTestDynamicOverlay.targetDependency,
    ]
  )

  static let session = Feature.library(
    name: "SessionFeature",
    dependencies: [
      Feature.error.targetDependency,
      Dependency.composableArchitecture.targetDependency,
      Dependency.composablePresentation.targetDependency,
      Dependency.elixxirDAppsSDK.targetDependency,
      Dependency.xcTestDynamicOverlay.targetDependency,
    ]
  )
}

let package = Package(
  name: "example-app",
  platforms: [.iOS(.v15)],
  products: Feature.all.map(\.product),
  dependencies: Dependency.all.map(\.packageDependency),
  targets: Feature.all.flatMap(\.targets)
)
