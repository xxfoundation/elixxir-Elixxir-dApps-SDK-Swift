import Bindings
import XCTestDynamicOverlay

public struct E2ERequestAuthenticatedChannel {
  public var run: (Data, String) throws -> Int64

  public func callAsFunction(
    partnerContact: Data,
    myFactsString: String
  ) throws -> Int64 {
    try run(partnerContact, myFactsString)
  }
}

extension E2ERequestAuthenticatedChannel {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2ERequestAuthenticatedChannel {
    E2ERequestAuthenticatedChannel { partnerContact, myFactsString in
      var roundId: Int64 = 0
      try bindingsE2E.request(
        partnerContact,
        myFactsString: myFactsString,
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
