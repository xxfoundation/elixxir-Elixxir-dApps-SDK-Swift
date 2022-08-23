import Bindings
import XCTestDynamicOverlay

public struct ConnectionIsAuthenticated {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension ConnectionIsAuthenticated {
  public static func live(_ bindingsConnection: BindingsConnection) -> ConnectionIsAuthenticated {
    ConnectionIsAuthenticated { false }
  }

  public static func live(_ bindingsConnection: BindingsAuthenticatedConnection) -> ConnectionIsAuthenticated {
    ConnectionIsAuthenticated(run: bindingsConnection.isAuthenticated)
  }
}

extension ConnectionIsAuthenticated {
  public static let unimplemented = ConnectionIsAuthenticated(
    run: XCTUnimplemented("\(Self.self)", placeholder: false)
  )
}
