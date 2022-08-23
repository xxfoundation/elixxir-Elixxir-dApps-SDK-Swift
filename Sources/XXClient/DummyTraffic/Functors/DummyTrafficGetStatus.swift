import Bindings
import XCTestDynamicOverlay

public struct DummyTrafficGetStatus {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension DummyTrafficGetStatus {
  public static func live(_ bindingsDummyTraffic: BindingsDummyTraffic) -> DummyTrafficGetStatus {
    DummyTrafficGetStatus(run: bindingsDummyTraffic.getStatus)
  }
}

extension DummyTrafficGetStatus {
  public static let unimplemented = DummyTrafficGetStatus(
    run: XCTUnimplemented("\(Self.self)", placeholder: false)
  )
}
