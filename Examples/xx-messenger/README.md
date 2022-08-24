# xx-messenger

Example iOS messenger application built with **Elixxir dApps Swift SDK**.

![Swift 5.6](https://img.shields.io/badge/swift-5.6-orange.svg)
![platform iOS](https://img.shields.io/badge/platform-iOS-blue.svg)

## 🛠 Development

Open `XXMessenger.xcworkspace` in Xcode (≥13.4).

### Project structure

```
XXMessenger [Xcode Workspace]
 ├─ xx-messenger [Swift Package]
 |   ├─ AppFeature [Library]
 |   └─ ...
 └─ XXMessenger [Xcode Project]
     └─ XXMessenger (iOS) [iOS App Target]
```

### Build schemes

- Use `XXMessenger` scheme to build, test, and run the app.
- Use other schemes (like `AppFeature`) for building and testing individual libraries in isolation.

## 📄 License

Copyright © 2022 xx network SEZC

[License](LICENSE)
