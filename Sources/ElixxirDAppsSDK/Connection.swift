import Bindings

public struct Connection {
  public var isAuthenticated: () -> Bool
  public var getPartner: () -> Data
  public var send: MessageSender
  public var listen: MessageListener
}

extension Connection {
  public static func live(
    bindingsConnection: BindingsConnection
  ) -> Connection {
    Connection(
      isAuthenticated: { false },
      getPartner: {
        guard let data = bindingsConnection.getPartner() else {
          fatalError("BindingsConnection.getPartner returned `nil`")
        }
        return data
      },
      send: .live(bindingsConnection: bindingsConnection),
      listen: .live(bindingsConnection: bindingsConnection)
    )
  }

  public static func live(
    bindingsAuthenticatedConnection: BindingsAuthenticatedConnection
  ) -> Connection {
    Connection(
      isAuthenticated: bindingsAuthenticatedConnection.isAuthenticated,
      getPartner: {
        guard let data = bindingsAuthenticatedConnection.getPartner() else {
          fatalError("BindingsAuthenticatedConnection.getPartner returned `nil`")
        }
        return data
      },
      send: .live(bindingsAuthenticatedConnection: bindingsAuthenticatedConnection),
      listen: .live(bindingsAuthenticatedConnection: bindingsAuthenticatedConnection)
    )
  }
}

#if DEBUG
extension Connection {
  public static let failing = Connection(
    isAuthenticated: { fatalError("Not implemented") },
    getPartner: { fatalError("Not implemented") },
    send: .failing,
    listen: .failing
  )
}
#endif
