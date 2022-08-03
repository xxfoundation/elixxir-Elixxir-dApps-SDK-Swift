import Bindings
import XCTestDynamicOverlay

public struct CMixIsHealthy {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension CMixIsHealthy {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixIsHealthy {
    CMixIsHealthy(run: bindingsCMix.isHealthy)
  }
}

extension CMixIsHealthy {
  public static let unimplemented = CMixIsHealthy(
    run: XCTUnimplemented("\(Self.self)")
  )
}
