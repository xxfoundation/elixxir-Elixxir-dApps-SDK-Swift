import Bindings
import XCTestDynamicOverlay

public struct ConnectionGetId {
  public var run: () -> Int

  public func callAsFunction() -> Int {
    run()
  }
}

extension ConnectionGetId {
  public static func live(_ bindingsConnection: BindingsConnection) -> ConnectionGetId {
    ConnectionGetId(run: bindingsConnection.getId)
  }

  public static func live(_ bindingsConnection: BindingsAuthenticatedConnection) -> ConnectionGetId {
    ConnectionGetId(run: bindingsConnection.getId)
  }
}

extension ConnectionGetId {
  public static let unimplemented = ConnectionGetId(
    run: XCTUnimplemented("\(Self.self)", placeholder: 0)
  )
}
