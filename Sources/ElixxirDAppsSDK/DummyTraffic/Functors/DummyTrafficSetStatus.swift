import Bindings
import XCTestDynamicOverlay

public struct DummyTrafficSetStatus {
  public var run: (Bool) throws -> Void

  public func callAsFunction(_ status: Bool) throws {
    try run(status)
  }
}

extension DummyTrafficSetStatus {
  public static func live(_ bindingsDummyTraffic: BindingsDummyTraffic) -> DummyTrafficSetStatus {
    DummyTrafficSetStatus(run: bindingsDummyTraffic.setStatus)
  }
}

extension DummyTrafficSetStatus {
  public static let unimplemented = DummyTrafficSetStatus(
    run: XCTUnimplemented("\(Self.self)")
  )
}
