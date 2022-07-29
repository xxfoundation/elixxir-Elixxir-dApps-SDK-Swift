import Bindings
import XCTestDynamicOverlay

public struct CmixMakeLegacyReceptionIdentity {
  public var run: () throws -> ReceptionIdentity

  public func callAsFunction() throws -> ReceptionIdentity {
    try run()
  }
}

extension CmixMakeLegacyReceptionIdentity {
  public static func live(_ bindingsCmix: BindingsCmix) -> CmixMakeLegacyReceptionIdentity {
    CmixMakeLegacyReceptionIdentity {
      let data = try bindingsCmix.makeLegacyReceptionIdentity()
      return try ReceptionIdentity.decode(data)
    }
  }
}

extension CmixMakeLegacyReceptionIdentity {
  public static let unimplemented = CmixMakeLegacyReceptionIdentity(
    run: XCTUnimplemented("\(Self.self)")
  )
}
