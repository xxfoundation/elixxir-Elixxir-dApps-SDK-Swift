import Bindings

public struct ConnectionCloser {
  public var close: () throws -> Void

  public func callAsFunction() throws {
    try close()
  }
}

extension ConnectionCloser {
  public static func live(
    bindingsConnection: BindingsConnection
  ) -> ConnectionCloser {
    ConnectionCloser(close: bindingsConnection.close)
  }

  public static func live(
    bindingsAuthenticatedConnection: BindingsAuthenticatedConnection
  ) -> ConnectionCloser {
    ConnectionCloser(close: bindingsAuthenticatedConnection.close)
  }
}

#if DEBUG
extension ConnectionCloser {
  public static let failing = ConnectionCloser {
    fatalError("Not implemented")
  }
}
#endif
