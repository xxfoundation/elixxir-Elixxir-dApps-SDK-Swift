import Bindings

public struct Connection {
  public var isAuthenticated: () -> Bool
  public var getPartner: ConnectionPartnerProvider
  public var send: MessageSender
  public var listen: MessageListener
  public var close: ConnectionCloser
}

extension Connection {
  public static func live(
    bindingsConnection: BindingsConnection
  ) -> Connection {
    Connection(
      isAuthenticated: { false },
      getPartner: .live(bindingsConnection: bindingsConnection),
      send: .live(bindingsConnection: bindingsConnection),
      listen: .live(bindingsConnection: bindingsConnection),
      close: .live(bindingsConnection: bindingsConnection)
    )
  }

  public static func live(
    bindingsAuthenticatedConnection: BindingsAuthenticatedConnection
  ) -> Connection {
    Connection(
      isAuthenticated: bindingsAuthenticatedConnection.isAuthenticated,
      getPartner: .live(bindingsAuthenticatedConnection: bindingsAuthenticatedConnection),
      send: .live(bindingsAuthenticatedConnection: bindingsAuthenticatedConnection),
      listen: .live(bindingsAuthenticatedConnection: bindingsAuthenticatedConnection),
      close: .live(bindingsAuthenticatedConnection: bindingsAuthenticatedConnection)
    )
  }
}

#if DEBUG
extension Connection {
  public static let failing = Connection(
    isAuthenticated: { fatalError("Not implemented") },
    getPartner: .failing,
    send: .failing,
    listen: .failing,
    close: .failing
  )
}
#endif
