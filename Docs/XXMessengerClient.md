# XXMessengerClient

`XXMessengerClient` is a client wrapper library for use in xx-messenger application.

## ▶️ Instantiate messenger

Example:

```swift
// setup environment:
var environment: MessengerEnvironment = .live()

// change cMix NDF environment if needed:
environment.ndfEnvironment = ...

// use alternative user-discovery if needed:
environment.udAddress = ...
environment.udCert = ...
environment.udContact = ...

// instantiate messenger:
let messenger: Messenger = .live(environment)
```

## 🚀 Start messenger

Example:

```swift
// allow cancellation of auth callbacks registration:
var authCallbacksCancellable: Cancellable?

func start(messenger: Messenger) throws {
  // check if messenger is loaded:
  if messenger.isLoaded() == false {
    // check if messenger is created and stored on disk:
    if messenger.isCreated() == false {
      // create new messenger and store it on disk:
      try messenger.create()
    }
    // load messenger stored on disk:
    try messenger.load()
  }

  // start messenger's network follower:
  try messenger.start()

  // register auth callbacks before connecting:
  authCallbacksCancellable = messenger.registerAuthCallbacks(
    AuthCallbacks(handle: { callback in
      // implement auth callbacks handling
    })
  )

  // check if messenger is connected:
  if messenger.isConnected() == false {
    // start end-to-end connection:
    try messenger.connect()
  }

  // check if messenger is logged in with user-discovery:
  if messenger.isLoggedIn() == false {
    // check if messenger is registered with user-discovery:
    if try messenger.isRegistered() == false {
      // register new user with user-discovery:
      try messenger.register(username: "new-username")
    } else {
      // login previously registered user with user-discovery:
      try messenger.logIn()
    }
  }
}
```

## 🛠 Use client components directly

Example:

```swift
// get cMix:
let cMix = messenger.cMix()

// get E2E:
let e2e = messenger.e2e()

// get UserDicovery:
let ud = messenger.ud()
```