import Bindings

public struct Client {
  public var networkFollower: NetworkFollower
  public var waitForNetwork: NetworkWaiter
}

extension Client {
  public static func live(bindingsClient: BindingsClient) -> Client {
    Client(
      networkFollower: .live(bindingsClient: bindingsClient),
      waitForNetwork: .live(bindingsClient: bindingsClient)
    )
  }
}

#if DEBUG
extension Client {
  public static let failing = Client(
    networkFollower: .failing,
    waitForNetwork: .failing
  )
}
#endif
