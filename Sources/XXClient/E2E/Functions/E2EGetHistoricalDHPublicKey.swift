import Bindings
import XCTestDynamicOverlay

public struct E2EGetHistoricalDHPublicKey {
  public var run: () throws -> Data

  public func callAsFunction() throws -> Data {
    try run()
  }
}

extension E2EGetHistoricalDHPublicKey {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EGetHistoricalDHPublicKey {
    E2EGetHistoricalDHPublicKey(run: bindingsE2E.getHistoricalDHPubkey)
  }
}

extension E2EGetHistoricalDHPublicKey {
  public static let unimplemented = E2EGetHistoricalDHPublicKey(
    run: XCTUnimplemented("\(Self.self)")
  )
}
