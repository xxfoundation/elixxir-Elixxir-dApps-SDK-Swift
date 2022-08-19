import Bindings
import XCTestDynamicOverlay

public struct E2EGetHistoricalDHPrivateKey {
  public var run: () throws -> Data

  public func callAsFunction() throws -> Data {
    try run()
  }
}

extension E2EGetHistoricalDHPrivateKey {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EGetHistoricalDHPrivateKey {
    E2EGetHistoricalDHPrivateKey(run: bindingsE2E.getHistoricalDHPrivkey)
  }
}

extension E2EGetHistoricalDHPrivateKey {
  public static let unimplemented = E2EGetHistoricalDHPrivateKey(
    run: XCTUnimplemented("\(Self.self)")
  )
}
