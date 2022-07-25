import Bindings
import XCTestDynamicOverlay

public struct E2EPayloadSize {
  public var run: () -> Int

  public func callAsFunction() -> Int {
    run()
  }
}

extension E2EPayloadSize {
  public static func live(bindingsE2E: BindingsE2e) -> E2EPayloadSize {
    E2EPayloadSize(run: bindingsE2E.payloadSize)
  }
}

extension E2EPayloadSize {
  public static let unimplemented = E2EPayloadSize(
    run: XCTUnimplemented("\(Self.self)")
  )
}
