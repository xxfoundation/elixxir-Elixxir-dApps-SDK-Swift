import Bindings

public struct Connection {
  public var isAuthenticated: () -> Bool
  public var send: MessageSender
}

extension Connection {
  public static func live(
    bindingsConnection: BindingsConnection
  ) -> Connection {
    Connection(
      isAuthenticated: { false },
      send: .live(bindingsConnection: bindingsConnection)
    )
  }

  public static func live(
    bindingsAuthenticatedConnection: BindingsAuthenticatedConnection
  ) -> Connection {
    Connection(
      isAuthenticated: bindingsAuthenticatedConnection.isAuthenticated,
      send: .live(bindingsAuthenticatedConnection: bindingsAuthenticatedConnection)
    )
  }
}

#if DEBUG
extension Connection {
  public static let failing = Connection(
    isAuthenticated: { false },
    send: .failing
  )
}
#endif
