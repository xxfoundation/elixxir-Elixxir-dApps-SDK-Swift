import Bindings
import XCTestDynamicOverlay

public struct E2EGetUdAddressFromNdf {
  public var run: () -> String

  public func callAsFunction() -> String {
    run()
  }
}

extension E2EGetUdAddressFromNdf {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EGetUdAddressFromNdf {
    E2EGetUdAddressFromNdf(run: bindingsE2E.getUdAddressFromNdf)
  }
}

extension E2EGetUdAddressFromNdf {
  public static let unimplemented = E2EGetUdAddressFromNdf(
    run: XCTUnimplemented("\(Self.self)")
  )
}
