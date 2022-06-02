import Bindings

public struct NetworkFollowerStarter {
  public var start: (_ timeoutMS: Int) throws -> Void

  public func callAsFunction(timeoutMS: Int) throws {
    try start(timeoutMS)
  }
}

extension NetworkFollowerStarter {
  public static func live(bindingsClient: BindingsClient) -> NetworkFollowerStarter {
    NetworkFollowerStarter { timeoutMS in
      try bindingsClient.startNetworkFollower(timeoutMS)
    }
  }
}

#if DEBUG
extension NetworkFollowerStarter {
  public static let failing = NetworkFollowerStarter { _ in
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
