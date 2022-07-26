import Bindings
import XCTestDynamicOverlay

public struct E2EVerifyOwnership {
  public var run: (Data, Data, Int) throws -> Bool

  public func callAsFunction(
    receivedContact: Data,
    verifiedContact: Data,
    e2eId: Int
  ) throws -> Bool {
    try run(receivedContact, verifiedContact, e2eId)
  }
}

extension E2EVerifyOwnership {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EVerifyOwnership {
    E2EVerifyOwnership { receivedContact, verifiedContact, e2eId in
      var result: ObjCBool = false
      try bindingsE2E.verifyOwnership(
        receivedContact,
        verifiedContact: verifiedContact,
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
