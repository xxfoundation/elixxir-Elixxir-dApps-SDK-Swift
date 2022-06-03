import Bindings

public struct NetworkFollowerStopper {
  public var stop: () throws -> Void

  public func callAsFunction() throws {
    try stop()
  }
}

extension NetworkFollowerStopper {
  public static func live(bindingsClient: BindingsClient) -> NetworkFollowerStopper {
    NetworkFollowerStopper(stop: bindingsClient.stopNetworkFollower)
  }
}

#if DEBUG
extension NetworkFollowerStopper {
  public static let failing = NetworkFollowerStopper {
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
