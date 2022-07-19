import Bindings

public struct ConnectionAuthStatusProvider {
  public var isAuthenticated: () -> Bool

  public func callAsFunction() -> Bool {
    isAuthenticated()
  }
}

extension ConnectionAuthStatusProvider {
  public static func live(
    bindingsConnection: BindingsConnection
  ) -> ConnectionAuthStatusProvider {
    ConnectionAuthStatusProvider { false }
  }

  public static func live(
    bindingsAuthenticatedConnection: BindingsAuthenticatedConnection
  ) -> ConnectionAuthStatusProvider {
    ConnectionAuthStatusProvider(
      isAuthenticated: bindingsAuthenticatedConnection.isAuthenticated
    )
  }
}

#if DEBUG
extension ConnectionAuthStatusProvider {
  public static let failing = ConnectionAuthStatusProvider {
    fatalError("Not implemented")
  }
}
#endif
