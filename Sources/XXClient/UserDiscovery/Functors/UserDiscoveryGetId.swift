import Bindings
import XCTestDynamicOverlay

public struct UserDiscoveryGetId {
  public var run: () -> Int

  public func callAsFunction() -> Int {
    run()
  }
}

extension UserDiscoveryGetId {
  public static func live(_ bindingsUD: BindingsUserDiscovery) -> UserDiscoveryGetId {
    UserDiscoveryGetId(run: bindingsUD.getID)
  }
}

extension UserDiscoveryGetId {
  public static let unimplemented = UserDiscoveryGetId(
    run: XCTUnimplemented("\(Self.self)", placeholder: 0)
  )
}
