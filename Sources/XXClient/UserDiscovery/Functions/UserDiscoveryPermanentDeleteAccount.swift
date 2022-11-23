import Bindings
import XCTestDynamicOverlay

public struct UserDiscoveryPermanentDeleteAccount {
  public var run: (Fact) throws -> Void

  public func callAsFunction(username: Fact) throws {
    try run(username)
  }
}

extension UserDiscoveryPermanentDeleteAccount {
  public static func live(_ bindingsUD: BindingsUserDiscovery) -> UserDiscoveryPermanentDeleteAccount {
    UserDiscoveryPermanentDeleteAccount { username in
      try bindingsUD.permanentDeleteAccount(username.encode())
    }
  }
}

extension UserDiscoveryPermanentDeleteAccount {
  public static let unimplemented = UserDiscoveryPermanentDeleteAccount(
    run: XCTUnimplemented("\(Self.self)")
  )
}
