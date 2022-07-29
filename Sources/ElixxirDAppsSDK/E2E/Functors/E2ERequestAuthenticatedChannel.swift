import Bindings
import XCTestDynamicOverlay

public struct E2ERequestAuthenticatedChannel {
  public var run: (Data, [Fact]) throws -> Int64

  public func callAsFunction(
    partnerContact: Data,
    myFacts: [Fact]
  ) throws -> Int64 {
    try run(partnerContact, myFacts)
  }
}

extension E2ERequestAuthenticatedChannel {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2ERequestAuthenticatedChannel {
    E2ERequestAuthenticatedChannel { partnerContact, myFacts in
      var roundId: Int64 = 0
      try bindingsE2E.request(
        partnerContact,
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
