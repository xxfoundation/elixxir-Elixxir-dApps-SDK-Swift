import Bindings
import XCTestDynamicOverlay

public struct E2ESend {
  public var run: (Int, Data, Data, Data) throws -> Data

  public func callAsFunction(
    messageType: Int,
    recipientId: Data,
    payload: Data,
    e2eParams: Data
  ) throws -> Data {
    try run(messageType, recipientId, payload, e2eParams)
  }
}

extension E2ESend {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2ESend {
    E2ESend(run: bindingsE2E.sendE2E(_:recipientId:payload:e2eParams:))
  }
}

extension E2ESend {
  public static let unimplemented = E2ESend(
    run: XCTUnimplemented("\(Self.self)")
  )
}
