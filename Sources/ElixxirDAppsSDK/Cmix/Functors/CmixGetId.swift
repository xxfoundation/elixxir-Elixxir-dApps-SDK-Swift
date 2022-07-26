import Bindings
import XCTestDynamicOverlay

public struct CmixGetId {
  public var run: () -> Int

  public func callAsFunction() -> Int {
    run()
  }
}

extension CmixGetId {
  public static func live(_ bindingsCmix: BindingsCmix) -> CmixGetId {
    CmixGetId(run: bindingsCmix.getID)
  }
}

extension CmixGetId {
  public static let unimplemented = CmixGetId(
    run: XCTUnimplemented("\(Self.self)")
  )
}
