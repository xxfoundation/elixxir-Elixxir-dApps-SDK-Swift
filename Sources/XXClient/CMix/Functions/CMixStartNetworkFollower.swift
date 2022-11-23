import Bindings
import XCTestDynamicOverlay

public struct CMixStartNetworkFollower {
  public var run: (Int) throws -> Void

  public func callAsFunction(timeoutMS: Int) throws {
    try run(timeoutMS)
  }
}

extension CMixStartNetworkFollower {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixStartNetworkFollower {
    CMixStartNetworkFollower { timeoutMS in
      try bindingsCMix.startNetworkFollower(timeoutMS)
    }
  }
}

extension CMixStartNetworkFollower {
  public static let unimplemented = CMixStartNetworkFollower(
    run: XCTUnimplemented("\(Self.self)")
  )
}
