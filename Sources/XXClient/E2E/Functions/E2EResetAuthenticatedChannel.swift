import Bindings
import XCTestDynamicOverlay

public struct E2EResetAuthenticatedChannel {
  public var run: (Contact) throws -> Int64

  public func callAsFunction(partner: Contact) throws -> Int64 {
    try run(partner)
  }
}

extension E2EResetAuthenticatedChannel {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EResetAuthenticatedChannel {
    E2EResetAuthenticatedChannel { partner in
      var roundId: Int64 = 0
      try bindingsE2E.reset(partner.data, ret0_: &roundId)
      return roundId
    }
  }
}

extension E2EResetAuthenticatedChannel {
  public static let unimplemented = E2EResetAuthenticatedChannel(
    run: XCTUnimplemented("\(Self.self)")
  )
}
