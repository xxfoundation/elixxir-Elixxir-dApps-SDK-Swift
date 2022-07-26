import Bindings
import XCTestDynamicOverlay

public struct E2EGetReceivedRequest {
  public var run: (Data) throws -> Data

  public func callAsFunction(partnerId: Data) throws -> Data {
    try run(partnerId)
  }
}

extension E2EGetReceivedRequest {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EGetReceivedRequest {
    E2EGetReceivedRequest(run: bindingsE2E.getReceivedRequest(_:))
  }
}

extension E2EGetReceivedRequest {
  public static let unimplemented = E2EGetReceivedRequest(
    run: XCTUnimplemented("\(Self.self)")
  )
}
