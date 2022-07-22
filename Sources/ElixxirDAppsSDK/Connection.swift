import Bindings

public struct Connection {
  // TODO:
}

extension Connection {
  public static func live(_ bindingsConnection: BindingsConnection) -> Connection {
    Connection()
  }

  public static func live(_ bindingsConnection: BindingsAuthenticatedConnection) -> Connection {
    Connection()
  }
}

extension Connection {
  public static let unimplemented = Connection()
}
