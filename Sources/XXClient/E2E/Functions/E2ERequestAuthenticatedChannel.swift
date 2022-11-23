import Bindings
import XCTestDynamicOverlay

public struct E2ERequestAuthenticatedChannel {
  public var run: (Contact, [Fact]) throws -> Int64

  public func callAsFunction(
    partner: Contact,
    myFacts: [Fact]
  ) throws -> Int64 {
    try run(partner, myFacts)
  }
}

extension E2ERequestAuthenticatedChannel {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2ERequestAuthenticatedChannel {
    E2ERequestAuthenticatedChannel { partner, myFacts in
      var roundId: Int64 = 0
      try bindingsE2E.request(
        partner.data,
        factsListJson: try myFacts.encode(),
        ret0_: &roundId
      )
      return roundId
    }
  }
}

extension E2ERequestAuthenticatedChannel {
  public static let unimplemented = E2ERequestAuthenticatedChannel(
    run: XCTUnimplemented("\(Self.self)")
  )
}
