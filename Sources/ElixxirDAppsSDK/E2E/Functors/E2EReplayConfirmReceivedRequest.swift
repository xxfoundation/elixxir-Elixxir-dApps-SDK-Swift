import Bindings
import XCTestDynamicOverlay

public struct E2EReplayConfirmReceivedRequest {
  public var run: (Data) throws -> Int64

  public func callAsFunction(
    partnerId: Data
  ) throws -> Int64 {
    try run(partnerId)
  }
}

extension E2EReplayConfirmReceivedRequest {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EReplayConfirmReceivedRequest {
    E2EReplayConfirmReceivedRequest { partnerId in
      var result: Int64 = 0
      try bindingsE2E.replayConfirm(partnerId, ret0_: &result)
      return result
    }
  }
}

extension E2EReplayConfirmReceivedRequest {
  public static let unimplemented = E2EReplayConfirmReceivedRequest(
    run: XCTUnimplemented("\(Self.self)")
  )
}
