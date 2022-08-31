import Bindings
import XCTestDynamicOverlay

public struct CMixNetworkFollowerStatus {
  public var run: () -> NetworkFollowerStatus

  public func callAsFunction() -> NetworkFollowerStatus {
    run()
  }
}

extension CMixNetworkFollowerStatus {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixNetworkFollowerStatus {
    CMixNetworkFollowerStatus {
      NetworkFollowerStatus(
        rawValue: bindingsCMix.networkFollowerStatus()
      )
    }
  }
}

extension CMixNetworkFollowerStatus {
  public static let unimplemented = CMixNetworkFollowerStatus(
    run: XCTUnimplemented("\(Self.self)", placeholder: .unknown(code: -1))
  )
}
