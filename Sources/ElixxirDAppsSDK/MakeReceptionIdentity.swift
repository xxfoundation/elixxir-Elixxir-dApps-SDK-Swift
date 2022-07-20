import Bindings
import XCTestDynamicOverlay

public struct MakeReceptionIdentity {
  public var run: () throws -> Data

  public func callAsFunction() throws -> Data {
    try run()
  }
}

extension MakeReceptionIdentity {
  public static func live(_ bindingsCmix: BindingsCmix) -> MakeReceptionIdentity {
    MakeReceptionIdentity(run: bindingsCmix.makeReceptionIdentity)
  }
}

extension MakeReceptionIdentity {
  public static let unimplemented = MakeReceptionIdentity(
    run: XCTUnimplemented("\(Self.self)")
  )
}
