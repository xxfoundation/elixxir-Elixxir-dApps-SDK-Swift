import Bindings
import XCTestDynamicOverlay

public struct CmixHasRunningProcesses {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension CmixHasRunningProcesses {
  public static func live(_ bindingsCmix: BindingsCmix) -> CmixHasRunningProcesses {
    CmixHasRunningProcesses(run: bindingsCmix.hasRunningProcessies)
  }
}

extension CmixHasRunningProcesses {
  public static let unimplemented = CmixHasRunningProcesses(
    run: XCTUnimplemented("\(Self.self)")
  )
}
