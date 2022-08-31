import Bindings
import XCTestDynamicOverlay

public struct UserDiscoveryRemoveFact {
  public var run: (Fact) throws -> Void

  public func callAsFunction(_ fact: Fact) throws {
    try run(fact)
  }
}

extension UserDiscoveryRemoveFact {
  public static func live(_ bindingsUD: BindingsUserDiscovery) -> UserDiscoveryRemoveFact {
    UserDiscoveryRemoveFact { fact in
      try bindingsUD.removeFact(fact.encode())
    }
  }
}

extension UserDiscoveryRemoveFact {
  public static let unimplemented = UserDiscoveryRemoveFact(
    run: XCTUnimplemented("\(Self.self)")
  )
}
