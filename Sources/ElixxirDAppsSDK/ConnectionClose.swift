import Bindings
import XCTestDynamicOverlay

public struct ConnectionClose {
  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }
}

extension ConnectionClose {
  public static func live(_ bindingsConnection: BindingsConnection) -> ConnectionClose {
    ConnectionClose(run: bindingsConnection.close)
  }

  public static func live(_ bindingsConnection: BindingsAuthenticatedConnection) -> ConnectionClose {
    ConnectionClose(run: bindingsConnection.close)
  }
}

extension ConnectionClose {
  public static let unimplemented = ConnectionClose(
    run: XCTUnimplemented("\(Self.self)")
  )
}
