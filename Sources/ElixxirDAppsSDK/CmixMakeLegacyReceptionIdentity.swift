import Bindings
import XCTestDynamicOverlay

public struct CmixMakeLegacyReceptionIdentity {
  public var run: () throws -> Data

  public func callAsFunction() throws -> Data {
    try run()
  }
}

extension CmixMakeLegacyReceptionIdentity {
  public static func live(_ bindingsCmix: BindingsCmix) -> CmixMakeLegacyReceptionIdentity {
    CmixMakeLegacyReceptionIdentity(run: bindingsCmix.makeLegacyReceptionIdentity)
  }
}

extension CmixMakeLegacyReceptionIdentity {
  public static let unimplemented = CmixMakeLegacyReceptionIdentity(
    run: XCTUnimplemented("\(Self.self)")
  )
}
