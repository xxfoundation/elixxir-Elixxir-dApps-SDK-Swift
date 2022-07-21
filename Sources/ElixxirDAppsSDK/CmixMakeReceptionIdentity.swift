import Bindings
import XCTestDynamicOverlay

public struct CmixMakeReceptionIdentity {
  public var run: () throws -> Data

  public func callAsFunction() throws -> Data {
    try run()
  }
}

extension CmixMakeReceptionIdentity {
  public static func live(_ bindingsCmix: BindingsCmix) -> CmixMakeReceptionIdentity {
    CmixMakeReceptionIdentity(run: bindingsCmix.makeReceptionIdentity)
  }
}

extension CmixMakeReceptionIdentity {
  public static let unimplemented = CmixMakeReceptionIdentity(
    run: XCTUnimplemented("\(Self.self)")
  )
}
