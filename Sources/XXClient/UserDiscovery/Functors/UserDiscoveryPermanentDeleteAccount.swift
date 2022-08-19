import Bindings
import XCTestDynamicOverlay

public struct UserDiscoveryPermanentDeleteAccount {
  public var run: (Fact) throws -> Void

  public func callAsFunction(_ fact: Fact) throws {
    try run(fact)
  }
}

extension UserDiscoveryPermanentDeleteAccount {
  public static func live(_ bindingsUD: BindingsUserDiscovery) -> UserDiscoveryPermanentDeleteAccount {
    UserDiscoveryPermanentDeleteAccount { fact in
      try bindingsUD.permanentDeleteAccount(fact.encode())
    }
  }
}

extension UserDiscoveryPermanentDeleteAccount {
  public static let unimplemented = UserDiscoveryPermanentDeleteAccount(
    run: XCTUnimplemented("\(Self.self)")
  )
}
