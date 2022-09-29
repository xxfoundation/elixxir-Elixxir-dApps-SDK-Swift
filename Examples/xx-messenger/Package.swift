// swift-tools-version: 5.7
import PackageDescription

let swiftSettings: [SwiftSetting] = [
  //.unsafeFlags(["-Xfrontend", "-warn-concurrency"], .when(configuration: .debug)),
  //.unsafeFlags(["-Xfrontend", "-debug-time-function-bodies"], .when(configuration: .debug)),
  //.unsafeFlags(["-Xfrontend", "-debug-time-expression-type-checking"], .when(configuration: .debug)),
]

let package = Package(
  name: "xx-messenger",
  platforms: [
    .iOS(.v15),
  ],
  products: [
    .library(name: "AppCore", targets: ["AppCore"]),
    .library(name: "AppFeature", targets: ["AppFeature"]),
    .library(name: "BackupFeature", targets: ["BackupFeature"]),
    .library(name: "ChatFeature", targets: ["ChatFeature"]),
    .library(name: "CheckContactAuthFeature", targets: ["CheckContactAuthFeature"]),
    .library(name: "ConfirmRequestFeature", targets: ["ConfirmRequestFeature"]),
    .library(name: "ContactFeature", targets: ["ContactFeature"]),
    .library(name: "ContactsFeature", targets: ["ContactsFeature"]),
    .library(name: "HomeFeature", targets: ["HomeFeature"]),
    .library(name: "MyContactFeature", targets: ["MyContactFeature"]),
    .library(name: "RegisterFeature", targets: ["RegisterFeature"]),
    .library(name: "RestoreFeature", targets: ["RestoreFeature"]),
    .library(name: "SendRequestFeature", targets: ["SendRequestFeature"]),
    .library(name: "UserSearchFeature", targets: ["UserSearchFeature"]),
    .library(name: "VerifyContactFeature", targets: ["VerifyContactFeature"]),
    .library(name: "WelcomeFeature", targets: ["WelcomeFeature"]),
  ],
  dependencies: [
    .package(
      path: "../../"
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture.git",
      .upToNextMajor(from: "0.40.2")
    ),
    .package(
      url: "https://git.xx.network/elixxir/client-ios-db.git",
      .upToNextMajor(from: "1.2.0")
    ),
    .package(
      url: "https://github.com/darrarski/swift-composable-presentation.git",
      .upToNextMajor(from: "0.5.3")
    ),
    .package(
      url: "https://github.com/pointfreeco/xctest-dynamic-overlay.git",
      .upToNextMajor(from: "0.4.1")
    ),
    .package(
      url: "https://github.com/pointfreeco/swift-custom-dump.git",
      .upToNextMajor(from: "0.5.2")
    ),
    .package(
      url: "https://github.com/kean/Pulse.git",
      .upToNextMajor(from: "2.1.2")
    ),
  ],
  targets: [
    .target(
      name: "AppCore",
      dependencies: [
        .product(name: "Pulse", package: "Pulse"),
        .product(name: "XCTestDynamicOverlay", package: "xctest-dynamic-overlay"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXDatabase", package: "client-ios-db"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXModels", package: "client-ios-db"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "AppCoreTests",
      dependencies: [
        .target(name: "AppCore"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "AppFeature",
      dependencies: [
        .target(name: "AppCore"),
        .target(name: "BackupFeature"),
        .target(name: "ChatFeature"),
        .target(name: "CheckContactAuthFeature"),
        .target(name: "ConfirmRequestFeature"),
        .target(name: "ContactFeature"),
        .target(name: "ContactsFeature"),
        .target(name: "HomeFeature"),
        .target(name: "MyContactFeature"),
        .target(name: "RegisterFeature"),
        .target(name: "RestoreFeature"),
        .target(name: "SendRequestFeature"),
        .target(name: "UserSearchFeature"),
        .target(name: "VerifyContactFeature"),
        .target(name: "WelcomeFeature"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        .product(name: "PulseUI", package: "Pulse"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXModels", package: "client-ios-db"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "AppFeatureTests",
      dependencies: [
        .target(name: "AppFeature"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "BackupFeature",
      dependencies: [
        .target(name: "AppCore"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXModels", package: "client-ios-db"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "BackupFeatureTests",
      dependencies: [
        .target(name: "BackupFeature"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "ChatFeature",
      dependencies: [
        .target(name: "AppCore"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXModels", package: "client-ios-db"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "ChatFeatureTests",
      dependencies: [
        .target(name: "ChatFeature"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "CheckContactAuthFeature",
      dependencies: [
        .target(name: "AppCore"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXModels", package: "client-ios-db"),
      ]
    ),
    .testTarget(
      name: "CheckContactAuthFeatureTests",
      dependencies: [
        .target(name: "CheckContactAuthFeature"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ]
    ),
    .target(
      name: "ConfirmRequestFeature",
      dependencies: [
        .target(name: "AppCore"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXModels", package: "client-ios-db"),
      ]
    ),
    .testTarget(
      name: "ConfirmRequestFeatureTests",
      dependencies: [
        .target(name: "ConfirmRequestFeature"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ]
    ),
    .target(
      name: "ContactFeature",
      dependencies: [
        .target(name: "AppCore"),
        .target(name: "ChatFeature"),
        .target(name: "CheckContactAuthFeature"),
        .target(name: "ConfirmRequestFeature"),
        .target(name: "SendRequestFeature"),
        .target(name: "VerifyContactFeature"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXModels", package: "client-ios-db"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "ContactFeatureTests",
      dependencies: [
        .target(name: "ContactFeature"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "ContactsFeature",
      dependencies: [
        .target(name: "AppCore"),
        .target(name: "ContactFeature"),
        .target(name: "MyContactFeature"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXModels", package: "client-ios-db"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "ContactsFeatureTests",
      dependencies: [
        .target(name: "ContactsFeature"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "HomeFeature",
      dependencies: [
        .target(name: "AppCore"),
        .target(name: "BackupFeature"),
        .target(name: "ContactsFeature"),
        .target(name: "RegisterFeature"),
        .target(name: "UserSearchFeature"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "ComposablePresentation", package: "swift-composable-presentation"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "HomeFeatureTests",
      dependencies: [
        .target(name: "HomeFeature"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "MyContactFeature",
      dependencies: [
        .target(name: "AppCore"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXModels", package: "client-ios-db"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "MyContactFeatureTests",
      dependencies: [
        .target(name: "MyContactFeature"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "RegisterFeature",
      dependencies: [
        .target(name: "AppCore"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXModels", package: "client-ios-db"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "RegisterFeatureTests",
      dependencies: [
        .target(name: "RegisterFeature"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "RestoreFeature",
      dependencies: [
        .target(name: "AppCore"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXModels", package: "client-ios-db"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "RestoreFeatureTests",
      dependencies: [
        .target(name: "RestoreFeature"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "SendRequestFeature",
      dependencies: [
        .target(name: "AppCore"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXModels", package: "client-ios-db"),
      ],
      swiftSettings: swiftSettings
    ),
    .testTarget(
      name: "SendRequestFeatureTests",
      dependencies: [
        .target(name: "SendRequestFeature"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
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
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ],
      swiftSettings: swiftSettings
    ),
    .target(
      name: "VerifyContactFeature",
      dependencies: [
        .target(name: "AppCore"),
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "XXClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXMessengerClient", package: "elixxir-dapps-sdk-swift"),
        .product(name: "XXModels", package: "client-ios-db"),
      ]
    ),
    .testTarget(
      name: "VerifyContactFeatureTests",
      dependencies: [
        .target(name: "VerifyContactFeature"),
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ]
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
        .product(name: "CustomDump", package: "swift-custom-dump"),
      ],
      swiftSettings: swiftSettings
    ),
  ]
)
