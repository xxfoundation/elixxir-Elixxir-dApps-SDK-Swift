import Bindings

public struct Connection {
  public var isAuthenticated: () -> Bool
}

extension Connection {
  public static func live(
    bindingsConnection: BindingsConnection
  ) -> Connection {
    Connection(
      isAuthenticated: { false }
    )
  }

  public static func live(
    bindingsAuthenticatedConnection: BindingsAuthenticatedConnection
  ) -> Connection {
    Connection(
      isAuthenticated: bindingsAuthenticatedConnection.isAuthenticated
    )
  }
}

#if DEBUG
extension Connection {
  public static let failing = Connection(
    isAuthenticated: { false }
  )
}
#endif
