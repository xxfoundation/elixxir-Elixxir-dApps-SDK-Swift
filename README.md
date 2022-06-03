# elixxir-dapps-sdk-swift

![Swift 5.6](https://img.shields.io/badge/swift-5.6-orange.svg)
![platform iOS](https://img.shields.io/badge/platform-iOS-blue.svg)

## 📖 Usage

Add `ElixxirDAppsSDK` library as a dependency to your project using Swift Package Manager.

For usage examples, checkout included example iOS application.

### ▶️ Instantiating client

Create a new client and store it on disk:

```swift
let createClient: ClientCreator = .live
try createClient(
  directoryURL: ...,
  ndf: ...,
  password: ...
)
```

Load existing client from disk:

```swift
let loadClient: ClientLoader = .live
let client = try loadClient(
  directoryURL: ..., 
  password: ...
)
```

You can also use a convenient `ClientStorage` wrapper to manage a client stored on disk:

```swift
let storage: ClientStorage = .live(
  passwordStorage: .init(
    save: { password in
      // securely save provided client's password
    },
    load: {
      // load securely stored client's password
    }
  )
)
let client: Client
if storage.hasStoredClient() {
  client = try storage.loadClient()
} else {
  client = try storage.createClient()
}
```

Check out included example iOS application for the `PasswordStorage` implementation that uses the iOS keychain.

### ▶️ Connecting to the network

Start network follower:

```
let client: Client = ...
try client.networkFollower.start(timeoutMS: 10_000)
```

Wait until connected:

```
let client: Client = ...
let isNetworkHealthy = client.waitForNetwork(timeoutMS: 30_000)
```

### ▶️ Making a new identity

Use the client to make a new identity:

```swift
let client: Client = ...
let myIdentity = try client.makeIdentity()
```

### ▶️ Connecting to remote

Perform auth key negotiation with the given recipient to get the `Connection`:

```swift
let client: Client = ...
let connection = try client.connect(
  withAuthentication: false,
  recipientContact: ..., 
  myIdentity: ...
)
```

Pass `true` for the `withAuthentication` parameter if you want to prove id ownership to remote as well.

### ▶️ Sending messages

Send a message to the connection's partner:

```swift
let connection: Connection = ...
let report = try connection.send(
  messageType: 1, 
  payload: ...
)
```

Check if the round succeeded:

```swift
let client: Client = ...
try client.waitForDelivery(roundList: ..., timeoutMS: 30_000) { result in
  switch result {
    case .delivered(let roundResults):
      ...
    case .notDelivered(let timedOut):
      ...
  }
}
```

### ▶️ Receiving messages

Use connection's message listener to receive messages from partner:

```swift
let connection: Connection = ...
connection.listen(messageType: 1) { message in
  ...
}
```

### ▶️ Using rest-like API

Use `RestlikeRequestSender` to perform rest-like requests:

```swift
let client: Client = ...
let connection: Connection = ...
let sendRestlike: RestlikeRequestSender = .live(authenticated: false)
let response = try sendRestlike(
  clientId: client.getId(),
  connectionId: connection.getId(),
  request: ...
)
```

Pass `true` for the `authenticated` parameter if you want to perform authenticated requests.

## 🛠 Development

Open `ElixxirDAppsSDK.xcworkspace` in Xcode (≥13.4).

### Project structure

```
ElixxirDAppsSDK [Xcode Workspace]
 ├─ elixxir-dapps-sdk-swift [Swift Package]
 |   └─ ElixxirDAppsSDK [Library]
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

- Use `exlixxir-dapps-sdk-swift` scheme to build the package with `ElixxirDAppsSDK` library.
- Use `ExampleApp (iOS)` to build and run the example app.
- Use `example-app` scheme to build and test the example app package with all contained libraries.
- Use `ExampleAppIcon` scheme with macOS target to build and preview the example app icon.
- Use `example-app-icon-export` scheme with macOS target to build and update the example app icon.
- Use other schemes, like `AppFeature`, for building and testing individual libraries in isolation.

## 📄 License

Copyright © 2022 xx network SEZC

[License](LICENSE)
