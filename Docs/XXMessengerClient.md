# XXMessengerClient

`XXMessengerClient` is a client wrapper library for use in xx-messenger application.

## ▶️ Instantiate messenger

### Example

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

### Example

```swift
// allow cancellation of callbacks:
var authCallbacksCancellable: Cancellable?
var messageListenerCancellable: Cancellable?

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
  
  // register message listener before connecting:
  messageListenerCancellable = messenger.registerMessageListener(
  	Listener(handle: { message in
  	  // handle incoming message
  	})
  )

  // check if messenger is connected:
  if messenger.isConnected() == false {
    // start end-to-end connection:
    try messenger.connect()
    // start listening for messanges:
    try messener.listenForMessages()
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

### Example

```swift
// get cMix:
let cMix = messenger.cMix()

// get E2E:
let e2e = messenger.e2e()

// get UserDicovery:
let ud = messenger.ud()

// get Backup:
let backup = messenger.backup()
```

## 💾 Backup

### Make backup

```swift
// start receiving backup data before starting or resuming backup:
let cancellable = messenger.registerBackupCallback(.init { data in
  // handle backup data, save on disk, upload to cloud, etc.
})

// check if backup is already running:
if messenger.isBackupRunning() == false {
  do {
    // try to resume previous backup:
    try messenger.resumeBackup()
  } catch {
    // try to start a new backup:
    let params: BackupParams = ...
    try messenger.startBackup(
      password: "backup-passphrase",
      params: params
    )
  }
}

// update params in the backup:
let params: BackupParams = ...
try messenger.backupParams(params)

// stop the backup:
try messenger.stopBackup()

// optionally stop receiving backup data
cancellable.cancel()
```

When starting a new backup you must provide `BackupParams` to prevent creating backups that does not contain it.

The registered backup callback can be reused later when a new backup is started. There is no need to cancel it and register a new callback in such a case.

### Restore from backup

```swift
let result = try messenger.restoreBackup(
  backupData: ...,
  backupPassphrase: "backup-passphrase"
)

// handle restoration result
```

If no error was thrown during restoration, the `Messenger` is already loaded, started, connected, and logged in.