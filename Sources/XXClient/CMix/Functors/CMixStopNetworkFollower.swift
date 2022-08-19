import Bindings
import XCTestDynamicOverlay

public struct CMixStopNetworkFollower {
  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }
}

extension CMixStopNetworkFollower {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixStopNetworkFollower {
    CMixStopNetworkFollower(run: bindingsCMix.stopNetworkFollower)
  }
}

extension CMixStopNetworkFollower {
  public static let unimplemented = CMixStopNetworkFollower(
    run: XCTUnimplemented("\(Self.self)")
  )
}
