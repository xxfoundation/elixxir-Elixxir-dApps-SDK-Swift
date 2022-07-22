import Bindings

public struct Connection {
  public var getId: ConnectionGetId
  public var getPartner: ConnectionGetPartner
  public var close: ConnectionClose
}

extension Connection {
  public static func live(_ bindingsConnection: BindingsConnection) -> Connection {
    Connection(
      getId: .live(bindingsConnection),
      getPartner: .live(bindingsConnection),
      close: .live(bindingsConnection)
    )
  }

  public static func live(_ bindingsConnection: BindingsAuthenticatedConnection) -> Connection {
    Connection(
      getId: .live(bindingsConnection),
      getPartner: .live(bindingsConnection),
      close: .live(bindingsConnection)
    )
  }
}

extension Connection {
  public static let unimplemented = Connection(
    getId: .unimplemented,
    getPartner: .unimplemented,
    close: .unimplemented
  )
}
