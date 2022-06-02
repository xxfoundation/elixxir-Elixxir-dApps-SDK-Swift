import Bindings

public struct NetworkFollower {
  public var status: NetworkFollowerStatusProvider
  public var start: NetworkFollowerStarter
  public var stop: NetworkFollowerStopper
}

extension NetworkFollower {
  public static func live(bindingsClient: BindingsClient) -> NetworkFollower {
    NetworkFollower(
      status: .live(bindingsClient: bindingsClient),
      start: .live(bindingsClient: bindingsClient),
      stop: .live(bindingsClient: bindingsClient)
    )
  }
}

#if DEBUG
extension NetworkFollower {
  public static let failing = NetworkFollower(
    status: .failing,
    start: .failing,
    stop: .failing
  )
}
#endif
