import Bindings
import XCTestDynamicOverlay

public struct UserDiscoveryGetFacts {
  public var run: () throws -> [Fact]

  public func callAsFunction() throws -> [Fact] {
    try run()
  }
}

extension UserDiscoveryGetFacts {
  public static func live(_ bindingsUD: BindingsUserDiscovery) -> UserDiscoveryGetFacts {
    UserDiscoveryGetFacts {
      guard let data = bindingsUD.getFacts() else {
        fatalError("BindingsUserDiscovery.getFacts returned `nil`")
      }
      return try [Fact].decode(data)
    }
  }
}

extension UserDiscoveryGetFacts {
  public static let unimplemented = UserDiscoveryGetFacts(
    run: XCTUnimplemented("\(Self.self)")
  )
}
