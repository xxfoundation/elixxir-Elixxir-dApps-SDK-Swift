import Bindings
import XCTestDynamicOverlay

public struct ConnectionSend {
  public var run: (Int, Data) throws -> E2ESendReport

  public func callAsFunction(
    messageType: Int,
    payload: Data
  ) throws -> E2ESendReport {
    try run(messageType, payload)
  }
}

extension ConnectionSend {
  public static func live(_ bindingsConnection: BindingsConnection) -> ConnectionSend {
    ConnectionSend { messageType, payload in
      try E2ESendReport.decode(
        bindingsConnection.sendE2E(messageType, payload: payload)
      )
    }
  }

  public static func live(_ bindingsConnection: BindingsAuthenticatedConnection) -> ConnectionSend {
    ConnectionSend { messageType, payload in
      try E2ESendReport.decode(
        bindingsConnection.sendE2E(messageType, payload: payload)
      )
    }
  }
}

extension ConnectionSend {
  public static let unimplemented = ConnectionSend(
    run: XCTUnimplemented("\(Self.self)")
  )
}
