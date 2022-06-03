import Bindings

public struct ConnectionIdProvider {
  public var get: () -> Int

  public func callAsFunction() -> Int {
    get()
  }
}

extension ConnectionIdProvider {
  public static func live(
    bindingsConnection: BindingsConnection
  ) -> ConnectionIdProvider {
    ConnectionIdProvider(get: bindingsConnection.getId)
  }

  public static func live(
    bindingsAuthenticatedConnection: BindingsAuthenticatedConnection
  ) -> ConnectionIdProvider {
    ConnectionIdProvider(get: bindingsAuthenticatedConnection.getId)
  }
}

#if DEBUG
extension ConnectionIdProvider {
  public static let failing = ConnectionIdProvider {
    fatalError("Not implemented")
  }
}
#endif
