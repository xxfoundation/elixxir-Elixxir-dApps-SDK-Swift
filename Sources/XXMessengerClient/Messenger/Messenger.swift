import XXClient

public struct Messenger {
  public var cMix: Stored<CMix?>
  public var e2e: Stored<E2E?>
  public var ud: Stored<UserDiscovery?>
  public var isCreated: MessengerIsCreated
  public var create: MessengerCreate
  public var isLoaded: MessengerIsLoaded
  public var load: MessengerLoad
  public var registerAuthCallbacks: MessengerRegisterAuthCallbacks
  public var start: MessengerStart
  public var isConnected: MessengerIsConnected
  public var connect: MessengerConnect
  public var isRegistered: MessengerIsRegistered
  public var register: MessengerRegister
  public var isLoggedIn: MessengerIsLoggedIn
  public var logIn: MessengerLogIn
  public var waitForNetwork: MessengerWaitForNetwork
  public var waitForNodes: MessengerWaitForNodes
  public var destroy: MessengerDestroy
}

extension Messenger {
  public static func live(_ env: MessengerEnvironment) -> Messenger {
    Messenger(
      cMix: env.cMix,
      e2e: env.e2e,
      ud: env.ud,
      isCreated: .live(env),
      create: .live(env),
      isLoaded: .live(env),
      load: .live(env),
      registerAuthCallbacks: .live(env),
      start: .live(env),
      isConnected: .live(env),
      connect: .live(env),
      isRegistered: .live(env),
      register: .live(env),
      isLoggedIn: .live(env),
      logIn: .live(env),
      waitForNetwork: .live(env),
      waitForNodes: .live(env),
      destroy: .live(env)
    )
  }
}

extension Messenger {
  public static let unimplemented = Messenger(
    cMix: .unimplemented(),
    e2e: .unimplemented(),
    ud: .unimplemented(),
    isCreated: .unimplemented,
    create: .unimplemented,
    isLoaded: .unimplemented,
    load: .unimplemented,
    registerAuthCallbacks: .unimplemented,
    start: .unimplemented,
    isConnected: .unimplemented,
    connect: .unimplemented,
    isRegistered: .unimplemented,
    register: .unimplemented,
    isLoggedIn: .unimplemented,
    logIn: .unimplemented,
    waitForNetwork: .unimplemented,
    waitForNodes: .unimplemented,
    destroy: .unimplemented
  )
}
