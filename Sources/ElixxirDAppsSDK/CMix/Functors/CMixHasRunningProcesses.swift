import Bindings
import XCTestDynamicOverlay

public struct CMixHasRunningProcesses {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension CMixHasRunningProcesses {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixHasRunningProcesses {
    CMixHasRunningProcesses(run: bindingsCMix.hasRunningProcessies)
  }
}

extension CMixHasRunningProcesses {
  public static let unimplemented = CMixHasRunningProcesses(
    run: XCTUnimplemented("\(Self.self)")
  )
}
