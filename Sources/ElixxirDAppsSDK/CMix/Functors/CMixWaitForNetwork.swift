import Bindings
import XCTestDynamicOverlay

public struct CMixWaitForNetwork {
  public var run: (Int) -> Bool

  public func callAsFunction(timeoutMS: Int) -> Bool {
    run(timeoutMS)
  }
}

extension CMixWaitForNetwork {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixWaitForNetwork {
    CMixWaitForNetwork(run: bindingsCMix.wait(forNetwork:))
  }
}

extension CMixWaitForNetwork {
  public static let unimplemented = CMixWaitForNetwork(
    run: XCTUnimplemented("\(Self.self)")
  )
}
