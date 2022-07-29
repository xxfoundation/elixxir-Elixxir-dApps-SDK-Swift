import Bindings
import XCTestDynamicOverlay

public struct E2EConfirmReceivedRequest {
  public var run: (Data) throws -> Int64

  public func callAsFunction(
    partnerContact: Data
  ) throws -> Int64 {
    try run(partnerContact)
  }
}

extension E2EConfirmReceivedRequest {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EConfirmReceivedRequest {
    E2EConfirmReceivedRequest { partnerContact in
      var result: Int64 = 0
      try bindingsE2E.confirm(partnerContact, ret0_: &result)
      return result
    }
  }
}

extension E2EConfirmReceivedRequest {
  public static let unimplemented = E2EConfirmReceivedRequest(
    run: XCTUnimplemented("\(Self.self)")
  )
}
