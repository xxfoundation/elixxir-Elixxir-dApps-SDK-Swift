import Bindings
import XCTestDynamicOverlay

public struct CmixNetworkFollowerStatus {
  public var run: () -> NetworkFollowerStatus

  public func callAsFunction() -> NetworkFollowerStatus {
    run()
  }
}

extension CmixNetworkFollowerStatus {
  public static func live(_ bindingsCmix: BindingsCmix) -> CmixNetworkFollowerStatus {
    CmixNetworkFollowerStatus {
      NetworkFollowerStatus(
        rawValue: bindingsCmix.networkFollowerStatus()
      )
    }
  }
}

extension CmixNetworkFollowerStatus {
  public static let unimplemented = CmixNetworkFollowerStatus(
    run: XCTUnimplemented("\(Self.self)")
  )
}
