import Bindings
import XCTestDynamicOverlay

public struct E2ECallAllReceivedRequests {
  public var run: () -> Void

  public func callAsFunction() {
    run()
  }
}

extension E2ECallAllReceivedRequests {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2ECallAllReceivedRequests {
    E2ECallAllReceivedRequests(run: bindingsE2E.callAllReceivedRequests)
  }
}

extension E2ECallAllReceivedRequests {
  public static let unimplemented = E2ECallAllReceivedRequests(
    run: XCTUnimplemented("\(Self.self)")
  )
}
