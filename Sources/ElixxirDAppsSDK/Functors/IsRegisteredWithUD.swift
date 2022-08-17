import Bindings
import XCTestDynamicOverlay

public struct IsRegisteredWithUD {
  public var run: (Int) throws -> Bool

  public func callAsFunction(e2eId: Int) throws -> Bool {
    try run(e2eId)
  }
}

extension IsRegisteredWithUD {
  public static let live = IsRegisteredWithUD { e2eId in
    var result: ObjCBool = false
    var error: NSError?
    BindingsIsRegisteredWithUD(
      e2eId,
      &result,
      &error
    )
    if let error = error {
      throw error
    }
    return result.boolValue
  }
}

extension IsRegisteredWithUD {
  public static let unimplemented = IsRegisteredWithUD(
    run: XCTUnimplemented("\(Self.self)")
  )
}
