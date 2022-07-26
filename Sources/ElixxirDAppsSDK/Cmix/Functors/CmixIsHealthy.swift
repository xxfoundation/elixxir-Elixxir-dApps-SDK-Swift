import Bindings
import XCTestDynamicOverlay

public struct CmixIsHealthy {
  public var run: () -> Bool

  public func callAsFunction() -> Bool {
    run()
  }
}

extension CmixIsHealthy {
  public static func live(_ bindingsCmix: BindingsCmix) -> CmixIsHealthy {
    CmixIsHealthy(run: bindingsCmix.isHealthy)
  }
}

extension CmixIsHealthy {
  public static let unimplemented = CmixIsHealthy(
    run: XCTUnimplemented("\(Self.self)")
  )
}
