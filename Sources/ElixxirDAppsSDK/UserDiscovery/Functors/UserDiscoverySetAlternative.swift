import Bindings
import XCTestDynamicOverlay

public struct UserDiscoverySetAlternative {
  public var run: (UserDiscoveryConfig?) throws -> Void

  public func callAsFunction(_ config: UserDiscoveryConfig?) throws {
    try run(config)
  }
}

extension UserDiscoverySetAlternative {
  public static func live(_ bindingsUD: BindingsUserDiscovery) -> UserDiscoverySetAlternative {
    UserDiscoverySetAlternative { config in
      if let config = config {
        try bindingsUD.setAlternative(
          config.cert,
          altAddress: config.address,
          contactFile: config.contact
        )
      } else {
        try bindingsUD.unsetAlternativeUserDiscovery()
      }
    }
  }
}

extension UserDiscoverySetAlternative {
  public static let unimplemented = UserDiscoverySetAlternative(
    run: XCTUnimplemented("\(Self.self)")
  )
}

