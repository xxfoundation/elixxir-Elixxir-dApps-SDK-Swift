import Bindings

public struct Client {
  public var getId: ClientIdProvider
  public var hasRunningProcesses: ClientProcessStatusProvider
  public var networkFollower: NetworkFollower
  public var waitForNetwork: NetworkWaiter
  public var isNetworkHealthy: NetworkHealthProvider
  public var monitorNetworkHealth: NetworkHealthListener
  public var listenErrors: ClientErrorListener
  public var makeIdentity: IdentityMaker
  public var connect: ConnectionMaker
  public var waitForDelivery: MessageDeliveryWaiter
}

extension Client {
  public static func live(bindingsClient: BindingsCmix) -> Client {
    Client(
      getId: .live(bindingsClient: bindingsClient),
      hasRunningProcesses: .live(bindingsClient: bindingsClient),
      networkFollower: .live(bindingsClient: bindingsClient),
      waitForNetwork: .live(bindingsClient: bindingsClient),
      isNetworkHealthy: .live(bindingsClient: bindingsClient),
      monitorNetworkHealth: .live(bindingsClient: bindingsClient),
      listenErrors: .live(bindingsClient: bindingsClient),
      makeIdentity: .live(bindingsClient: bindingsClient),
      connect: .live(bindingsClient: bindingsClient),
      waitForDelivery: .live(bindingsClient: bindingsClient)
    )
  }
}

#if DEBUG
extension Client {
  public static let failing = Client(
    getId: .failing,
    hasRunningProcesses: .failing,
    networkFollower: .failing,
    waitForNetwork: .failing,
    isNetworkHealthy: .failing,
    monitorNetworkHealth: .failing,
    listenErrors: .failing,
    makeIdentity: .failing,
    connect: .failing,
    waitForDelivery: .failing
  )
}
#endif
