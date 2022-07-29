import Bindings
import XCTestDynamicOverlay

public struct CmixStopNetworkFollower {
  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }
}

extension CmixStopNetworkFollower {
  public static func live(_ bindingsCmix: BindingsCmix) -> CmixStopNetworkFollower {
    CmixStopNetworkFollower(run: bindingsCmix.stopNetworkFollower)
  }
}

extension CmixStopNetworkFollower {
  public static let unimplemented = CmixStopNetworkFollower(
    run: XCTUnimplemented("\(Self.self)")
  )
}
