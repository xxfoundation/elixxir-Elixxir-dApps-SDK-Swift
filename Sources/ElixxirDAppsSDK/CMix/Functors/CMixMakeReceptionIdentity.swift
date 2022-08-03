import Bindings
import XCTestDynamicOverlay

public struct CMixMakeReceptionIdentity {
  public var run: () throws -> ReceptionIdentity

  public func callAsFunction() throws -> ReceptionIdentity {
    try run()
  }
}

extension CMixMakeReceptionIdentity {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixMakeReceptionIdentity {
    CMixMakeReceptionIdentity {
      let data = try bindingsCMix.makeReceptionIdentity()
      return try ReceptionIdentity.decode(data)
    }
  }
}

extension CMixMakeReceptionIdentity {
  public static let unimplemented = CMixMakeReceptionIdentity(
    run: XCTUnimplemented("\(Self.self)")
  )
}
