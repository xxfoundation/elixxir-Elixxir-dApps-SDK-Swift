import Bindings
import XCTestDynamicOverlay

public struct UserDiscoverySendRegisterFact {
  public var run: (Fact) throws -> String

  public func callAsFunction(_ fact: Fact) throws -> String {
    try run(fact)
  }
}

extension UserDiscoverySendRegisterFact {
  public static func live(_ bindingsUD: BindingsUserDiscovery) -> UserDiscoverySendRegisterFact {
    UserDiscoverySendRegisterFact { fact in
      var error: NSError?
      let confirmationId = bindingsUD.sendRegisterFact(try fact.encode(), error: &error)
      if let error = error {
        throw error
      }
      return confirmationId
    }
  }
}

extension UserDiscoverySendRegisterFact {
  public static let unimplemented = UserDiscoverySendRegisterFact(
    run: XCTUnimplemented("\(Self.self)")
  )
}
