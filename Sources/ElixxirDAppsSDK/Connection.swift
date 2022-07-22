import Bindings

public struct Connection {
  public var getId: ConnectionGetId
}

extension Connection {
  public static func live(_ bindingsConnection: BindingsConnection) -> Connection {
    Connection(
      getId: .live(bindingsConnection)
    )
  }

  public static func live(_ bindingsConnection: BindingsAuthenticatedConnection) -> Connection {
    Connection(
      getId: .live(bindingsConnection)
    )
  }
}

extension Connection {
  public static let unimplemented = Connection(
    getId: .unimplemented
  )
}
