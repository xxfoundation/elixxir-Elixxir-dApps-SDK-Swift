import Bindings
import XCTestDynamicOverlay

public struct UserDiscoveryConfirmFact {
  public var run: (String, String) throws -> Void

  public func callAsFunction(
    confirmationId: String,
    code: String
  ) throws {
    try run(confirmationId, code)
  }
}

extension UserDiscoveryConfirmFact {
  public static func live(_ bindingsUD: BindingsUserDiscovery) -> UserDiscoveryConfirmFact {
    UserDiscoveryConfirmFact(run: bindingsUD.confirmFact(_:code:))
  }
}

extension UserDiscoveryConfirmFact {
  public static let unimplemented = UserDiscoveryConfirmFact(
    run: XCTUnimplemented("\(Self.self)")
  )
}
