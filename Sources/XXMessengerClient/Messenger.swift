import XXClient

public struct Messenger {
  public var cMix: Stored<CMix?>
  public var e2e: Stored<E2E?>
  public var ud: Stored<UserDiscovery?>
  public var isCreated: IsCreated
  public var create: Create
  public var isLoaded: IsLoaded
  public var load: Load
  public var start: Start
  public var isConnected: IsConnected
  public var connect: Connect
  public var isRegistered: IsRegistered
  public var register: Register
  public var isLoggedIn: IsLoggedIn
  public var logIn: LogIn
  public var waitForNetwork: WaitForNetwork
  public var waitForNodes: WaitForNodes
}

extension Messenger {
  public static func live(_ env: Environment) -> Messenger {
    Messenger(
      cMix: env.cMix,
      e2e: env.e2e,
      ud: env.ud,
      isCreated: .live(env),
      create: .live(env),
      isLoaded: .live(env),
      load: .live(env),
      start: .live(env),
      isConnected: .live(env),
      connect: .live(env),
      isRegistered: .live(env),
      register: .live(env),
      isLoggedIn: .live(env),
      logIn: .live(env),
      waitForNetwork: .live(env),
      waitForNodes: .live(env)
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
    start: .unimplemented,
    isConnected: .unimplemented,
    connect: .unimplemented,
    isRegistered: .unimplemented,
    register: .unimplemented,
    isLoggedIn: .unimplemented,
    logIn: .unimplemented,
    waitForNetwork: .unimplemented,
    waitForNodes: .unimplemented
  )
}
