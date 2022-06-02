import Bindings

public struct ClientIdProvider {
  public var get: () -> Int

  public func callAsFunction() -> Int {
    get()
  }
}

extension ClientIdProvider {
  public static func live(bindingsClient: BindingsClient) -> ClientIdProvider {
    ClientIdProvider(get: bindingsClient.getID)
  }
}

#if DEBUG
extension ClientIdProvider {
  public static let failing = ClientIdProvider {
    fatalError("Not implemented")
  }
}
#endif
