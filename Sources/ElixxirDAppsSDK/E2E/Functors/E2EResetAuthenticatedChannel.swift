import Bindings
import XCTestDynamicOverlay

public struct E2EResetAuthenticatedChannel {
  public var run: (Data) throws -> Int64

  public func callAsFunction(partnerContact: Data) throws -> Int64 {
    try run(partnerContact)
  }
}

extension E2EResetAuthenticatedChannel {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EResetAuthenticatedChannel {
    E2EResetAuthenticatedChannel { partnerContact in
      var roundId: Int64 = 0
      try bindingsE2E.reset(partnerContact, ret0_: &roundId)
      return roundId
    }
  }
}

extension E2EResetAuthenticatedChannel {
  public static let unimplemented = E2EResetAuthenticatedChannel(
    run: XCTUnimplemented("\(Self.self)")
  )
}
