import Bindings
import XCTestDynamicOverlay

public struct UserDiscoveryGetContact {
  public var run: () throws -> Data

  public func callAsFunction() throws -> Data {
    try run()
  }
}

extension UserDiscoveryGetContact {
  public static func live(_ bindingsUD: BindingsUserDiscovery) -> UserDiscoveryGetContact {
    UserDiscoveryGetContact(run: bindingsUD.getContact)
  }
}

extension UserDiscoveryGetContact {
  public static let unimplemented = UserDiscoveryGetContact(
    run: XCTUnimplemented("\(Self.self)")
  )
}

