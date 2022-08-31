import Bindings
import XCTestDynamicOverlay

public struct E2EConfirmReceivedRequest {
  public var run: (Contact) throws -> Int64

  public func callAsFunction(
    partner: Contact
  ) throws -> Int64 {
    try run(partner)
  }
}

extension E2EConfirmReceivedRequest {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EConfirmReceivedRequest {
    E2EConfirmReceivedRequest { partner in
      var result: Int64 = 0
      try bindingsE2E.confirm(partner.data, ret0_: &result)
      return result
    }
  }
}

extension E2EConfirmReceivedRequest {
  public static let unimplemented = E2EConfirmReceivedRequest(
    run: XCTUnimplemented("\(Self.self)")
  )
}
