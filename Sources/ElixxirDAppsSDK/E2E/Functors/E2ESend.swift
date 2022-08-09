import Bindings
import XCTestDynamicOverlay

public struct E2ESend {
  public var run: (Int, Data, Data, Data) throws -> E2ESendReport

  public func callAsFunction(
    messageType: Int,
    recipientId: Data,
    payload: Data,
    e2eParams: Data
  ) throws -> E2ESendReport {
    try run(messageType, recipientId, payload, e2eParams)
  }
}

extension E2ESend {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2ESend {
    E2ESend { messageType, recipientId, payload, e2eParams in
      let reportData = try bindingsE2E.sendE2E(
        messageType,
        recipientId: recipientId,
        payload: payload,
        e2eParams: e2eParams
      )
      return try E2ESendReport.decode(reportData)
    }
  }
}

extension E2ESend {
  public static let unimplemented = E2ESend(
    run: XCTUnimplemented("\(Self.self)")
  )
}
