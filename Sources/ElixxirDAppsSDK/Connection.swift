import Bindings

public struct Connection {
  public var isAuthenticated: ConnectionIsAuthenticated
  public var getId: ConnectionGetId
  public var getPartner: ConnectionGetPartner
  public var registerListener: ConnectionRegisterListener
  public var send: ConnectionSend
  public var close: ConnectionClose
}

extension Connection {
  public static func live(_ bindingsConnection: BindingsConnection) -> Connection {
    Connection(
      isAuthenticated: .live(bindingsConnection),
      getId: .live(bindingsConnection),
      getPartner: .live(bindingsConnection),
      registerListener: .live(bindingsConnection),
      send: .live(bindingsConnection),
      close: .live(bindingsConnection)
    )
  }

  public static func live(_ bindingsConnection: BindingsAuthenticatedConnection) -> Connection {
    Connection(
      isAuthenticated: .live(bindingsConnection),
      getId: .live(bindingsConnection),
      getPartner: .live(bindingsConnection),
      registerListener: .live(bindingsConnection),
      send: .live(bindingsConnection),
      close: .live(bindingsConnection)
    )
  }
}

extension Connection {
  public static let unimplemented = Connection(
    isAuthenticated: .unimplemented,
    getId: .unimplemented,
    getPartner: .unimplemented,
    registerListener: .unimplemented,
    send: .unimplemented,
    close: .unimplemented
  )
}
