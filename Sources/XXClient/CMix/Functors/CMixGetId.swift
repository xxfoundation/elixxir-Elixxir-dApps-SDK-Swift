import Bindings
import XCTestDynamicOverlay

public struct CMixGetId {
  public var run: () -> Int

  public func callAsFunction() -> Int {
    run()
  }
}

extension CMixGetId {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixGetId {
    CMixGetId(run: bindingsCMix.getID)
  }
}

extension CMixGetId {
  public static let unimplemented = CMixGetId(
    run: XCTUnimplemented("\(Self.self)")
  )
}
