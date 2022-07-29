import Bindings
import XCTestDynamicOverlay

public struct E2EGetId {
  public var run: () -> Int

  public func callAsFunction() -> Int {
    run()
  }
}

extension E2EGetId {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EGetId {
      E2EGetId(run: bindingsE2E.getID)
  }
}

extension E2EGetId {
  public static let unimplemented = E2EGetId(
    run: XCTUnimplemented("\(Self.self)")
  )
}
