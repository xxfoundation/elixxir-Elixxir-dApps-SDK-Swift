import Bindings
import XCTestDynamicOverlay

public struct CMixMakeReceptionIdentity {
  public var run: (Bool) throws -> ReceptionIdentity

  public func callAsFunction(
    legacy: Bool = false
  ) throws -> ReceptionIdentity {
    try run(legacy)
  }
}

extension CMixMakeReceptionIdentity {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixMakeReceptionIdentity {
    CMixMakeReceptionIdentity { legacy in
      let data: Data
      if legacy {
        data = try bindingsCMix.makeLegacyReceptionIdentity()
      } else {
        data = try bindingsCMix.makeReceptionIdentity()
      }
      return try ReceptionIdentity.decode(data)
    }
  }
}

extension CMixMakeReceptionIdentity {
  public static let unimplemented = CMixMakeReceptionIdentity(
    run: XCTUnimplemented("\(Self.self)")
  )
}
