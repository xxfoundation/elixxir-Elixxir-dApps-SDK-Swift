import Bindings
import XCTestDynamicOverlay

public struct CMixMakeLegacyReceptionIdentity {
  public var run: () throws -> ReceptionIdentity

  public func callAsFunction() throws -> ReceptionIdentity {
    try run()
  }
}

extension CMixMakeLegacyReceptionIdentity {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixMakeLegacyReceptionIdentity {
    CMixMakeLegacyReceptionIdentity {
      let data = try bindingsCMix.makeLegacyReceptionIdentity()
      return try ReceptionIdentity.decode(data)
    }
  }
}

extension CMixMakeLegacyReceptionIdentity {
  public static let unimplemented = CMixMakeLegacyReceptionIdentity(
    run: XCTUnimplemented("\(Self.self)")
  )
}
