import Bindings
import XCTestDynamicOverlay

public struct E2EDeleteRequest {
  public var partnerId: (Data) throws -> Void
  public var received: () throws -> Void
  public var sent: () throws -> Void
  public var all: () throws -> Void
}

extension E2EDeleteRequest {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EDeleteRequest {
    E2EDeleteRequest(
      partnerId: bindingsE2E.deleteRequest(_:),
      received: bindingsE2E.deleteReceiveRequests,
      sent: bindingsE2E.deleteSentRequests,
      all: bindingsE2E.deleteAllRequests
    )
  }
}

extension E2EDeleteRequest {
  public static let unimplemented = E2EDeleteRequest(
    partnerId: XCTUnimplemented("\(Self.self).partnerId"),
    received: XCTUnimplemented("\(Self.self).received"),
    sent: XCTUnimplemented("\(Self.self).sent"),
    all: XCTUnimplemented("\(Self.self).all")
  )
}
