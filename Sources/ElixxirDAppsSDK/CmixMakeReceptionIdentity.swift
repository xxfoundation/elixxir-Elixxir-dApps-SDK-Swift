import Bindings
import XCTestDynamicOverlay

public struct CmixMakeReceptionIdentity {
  public var run: () throws -> ReceptionIdentity

  public func callAsFunction() throws -> ReceptionIdentity {
    try run()
  }
}

extension CmixMakeReceptionIdentity {
  public static func live(_ bindingsCmix: BindingsCmix) -> CmixMakeReceptionIdentity {
    CmixMakeReceptionIdentity {
      let data = try bindingsCmix.makeReceptionIdentity()
      return try ReceptionIdentity.decode(data)
    }
  }
}

extension CmixMakeReceptionIdentity {
  public static let unimplemented = CmixMakeReceptionIdentity(
    run: XCTUnimplemented("\(Self.self)")
  )
}
