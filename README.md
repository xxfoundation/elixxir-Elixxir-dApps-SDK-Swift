# Elixxir dApps Swift SDK

![Swift 5.6](https://img.shields.io/badge/swift-5.6-orange.svg)
![platform iOS](https://img.shields.io/badge/platform-iOS-blue.svg)

## 📖 Documentation 

- [XXClient Quick Start Guide](Docs/XXClient-quick-start-guide.md)
- [XXMessengerClient](Docs/XXMessengerClient.md)

## 📱 Demo

Checkout included example iOS application.

## 🛠 Development

Open `ElixxirDAppsSDK.xcworkspace` in Xcode (≥13.4).

### Project structure

```
ElixxirDAppsSDK [Xcode Workspace]
 ├─ elixxir-dapps-sdk-swift [Swift Package]
 |   ├─ XXClient [Library]
 |   └─ XXMessengerClient [Library]
 └─ Example [Xcode Project]
     ├─ ExampleApp (iOS) [iOS App Target]
     ├─ example-app [Swift Package]
     |   ├─ AppFeature [Library]
     |   └─ ...
     └─ example-app-icon [Swift Package] 
         ├─ ExampleAppIcon [Library]
         └─ example-app-icon-export [Executable]
```

### Build schemes

- Use `exlixxir-dapps-sdk-swift` scheme to build and test the package.
- Use `ExampleApp (iOS)` to build and run the example app.
- Use `example-app` scheme to build and test the example app package with all contained libraries.
- Use `ExampleAppIcon` scheme with macOS target to build and preview the example app icon.
- Use `example-app-icon-export` scheme with macOS target to build and update the example app icon.
- Use other schemes, like `XXClient`, for building and testing individual libraries in isolation.

## 📄 License

Copyright © 2022 xx network SEZC

[License](LICENSE)
