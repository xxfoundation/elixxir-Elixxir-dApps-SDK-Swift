import Bindings
import XCTestDynamicOverlay

public struct CmixWaitForNetwork {
  public var run: (Int) -> Bool

  public func callAsFunction(timeoutMS: Int) -> Bool {
    run(timeoutMS)
  }
}

extension CmixWaitForNetwork {
  public static func live(_ bindingsCmix: BindingsCmix) -> CmixWaitForNetwork {
    CmixWaitForNetwork(run: bindingsCmix.wait(forNetwork:))
  }
}

extension CmixWaitForNetwork {
  public static let unimplemented = CmixWaitForNetwork(
    run: XCTUnimplemented("\(Self.self)")
  )
}
