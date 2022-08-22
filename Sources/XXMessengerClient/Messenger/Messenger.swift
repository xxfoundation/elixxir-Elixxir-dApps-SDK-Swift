import XXClient

public struct Messenger {
  public var isCreated: MessengerIsCreated
  public var create: MessengerCreate
  public var isLoaded: MessengerIsLoaded
  public var load: MessengerLoad
  public var isConnected: MessengerIsConnected
  public var connect: MessengerConnect
  public var isRegistered: MessengerIsRegistered
  public var register: MessengerRegister
  public var isLoggedIn: MessengerIsLoggedIn
  public var logIn: MessengerLogIn
}

extension Messenger {
  public static func live(_ env: MessengerEnvironment) -> Messenger {
    Messenger(
      isCreated: .live(env),
      create: .live(env),
      isLoaded: .live(env),
      load: .live(env),
      isConnected: .live(env),
      connect: .live(env),
      isRegistered: .live(env),
      register: .live(env),
      isLoggedIn: .live(env),
      logIn: .live(env)
    )
  }
}

extension Messenger {
  public static let unimplemented = Messenger(
    isCreated: .unimplemented,
    create: .unimplemented,
    isLoaded: .unimplemented,
    load: .unimplemented,
    isConnected: .unimplemented,
    connect: .unimplemented,
    isRegistered: .unimplemented,
    register: .unimplemented,
    isLoggedIn: .unimplemented,
    logIn: .unimplemented
  )
}
