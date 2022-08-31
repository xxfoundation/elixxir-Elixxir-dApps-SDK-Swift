import Bindings
import XCTestDynamicOverlay

public struct E2EVerifyOwnership {
  public var run: (Contact, Contact, Int) throws -> Bool

  public func callAsFunction(
    received: Contact,
    verified: Contact,
    e2eId: Int
  ) throws -> Bool {
    try run(received, verified, e2eId)
  }
}

extension E2EVerifyOwnership {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EVerifyOwnership {
    E2EVerifyOwnership { received, verified, e2eId in
      var result: ObjCBool = false
      try bindingsE2E.verifyOwnership(
        received.data,
        verifiedContact: verified.data,
        e2eId: e2eId,
        ret0_: &result
      )
      return result.boolValue
    }
  }
}

extension E2EVerifyOwnership {
  public static let unimplemented = E2EVerifyOwnership(
    run: XCTUnimplemented("\(Self.self)")
  )
}
