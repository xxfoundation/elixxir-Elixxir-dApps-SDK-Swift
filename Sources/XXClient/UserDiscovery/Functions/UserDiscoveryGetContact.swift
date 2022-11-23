import Bindings
import XCTestDynamicOverlay

public struct UserDiscoveryGetContact {
  public var run: () throws -> Contact

  public func callAsFunction() throws -> Contact {
    try run()
  }
}

extension UserDiscoveryGetContact {
  public static func live(_ bindingsUD: BindingsUserDiscovery) -> UserDiscoveryGetContact {
    UserDiscoveryGetContact {
      Contact.live(try bindingsUD.getContact())
    }
  }
}

extension UserDiscoveryGetContact {
  public static let unimplemented = UserDiscoveryGetContact(
    run: XCTUnimplemented("\(Self.self)")
  )
}

