import Bindings
import XCTestDynamicOverlay

public struct E2EGetUdContactFromNdf {
  public var run: () throws -> Data

  public func callAsFunction() throws -> Data {
    try run()
  }
}

extension E2EGetUdContactFromNdf {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EGetUdContactFromNdf {
    E2EGetUdContactFromNdf(run: bindingsE2E.getUdContactFromNdf)
  }
}

extension E2EGetUdContactFromNdf {
  public static let unimplemented = E2EGetUdContactFromNdf(
    run: XCTUnimplemented("\(Self.self)")
  )
}
