# Elixxir dApps Swift SDK

![Swift 5.6](https://img.shields.io/badge/swift-5.6-orange.svg)
![platform iOS](https://img.shields.io/badge/platform-iOS-blue.svg)

## 📱 Demo

Refer to this [demo](https://git.xx.network/elixxir/shielded-help-demo/elixxir-dapp-demo) to see an example of how to build an app with the SDK to send `E2E` messages and send `RestLike` message.

Also you can checkout included example iOS application.

## 📖 Documentation 

You can find full documentation with step by step guide [here](https://xxdk-dev.xx.network/mobile%20docs/ios-sdk)

- [XXMessengerClient](Docs/XXMessengerClient.md)

## 🚀 Quick Start

Add `XXClient` library as a dependency to your project using Swift Package Manager.

### ▶️ Instantiating cMix

You can use a convenient `CMixManager` wrapper to manage cMix stored on disk:

```swift
let cMixManager: CMixManager = .live(
  passwordStorage: .init(
    save: { password in
      // securely save provided password
    },
    load: {
      // load securely stored password
    }
  )
)

let cMix: CMix
if cMixManager.hasStorage() {
  cMix = try cMixManager.load()
} else {
  cMix = try cMixManager.create()
}
```

Check out included example iOS application for the `PasswordStorage` implementation that uses the iOS keychain.

### ▶️ Connecting to the network

Start network follower:

```swift
try cMix.startNetworkFollower(timeoutMS: 10_000)
```

Wait until connected:

```swift
let isNetworkHealthy = try cMix.waitForNetwork(timeoutMS: 30_000)
```

### ▶️ Making a new reception identity

Use the cMix to make a new reception identity:

```swift
let myIdentity = try cMix.makeReceptionIdentity()
```

### ▶️ Create new E2E

```swift
let login: Login = .live
let e2e = try login(
  cMixId: cMix.getId(),
  identity: myIdentity
)
```

### ▶️ Connecting to remote

Perform auth key negotiation with the given recipient to get the `Connection`:

```swift
let connection = try cMix.connect(
  withAuthentication: false,
  e2eId: e2e.getId(),
  recipientContact: ...
)
```

Pass `true` for the `withAuthentication` parameter if you want to prove id ownership to remote as well.

### ▶️ Sending messages

Send a message to the connection's partner:

```swift
let sendReport = try connection.send(
  messageType: 1,
  payload: ...
)
```

Check if the round succeeded:

```swift
try cMix.waitForRoundResult(
  roundList: try sendReport.encode(),
  timeoutMS: 30_000,
  callback: .init { result in
    switch result {
    case .delivered(let roundResults):
      ...
    case .notDelivered(let timedOut):
      ...
    }
  }
)
```

### ▶️ Receiving messages

Use connection's message listener to receive messages from partner:

```swift
try connection.registerListener(
  messageType: 1,
  listener: .init { message in
    ...
  }
)
```

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
