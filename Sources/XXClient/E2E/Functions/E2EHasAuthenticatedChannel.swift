import Bindings
import XCTestDynamicOverlay

public struct E2EHasAuthenticatedChannel {
  public var run: (Data) throws -> Bool

  public func callAsFunction(partnerId: Data) throws -> Bool {
    try run(partnerId)
  }
}

extension E2EHasAuthenticatedChannel {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2EHasAuthenticatedChannel {
    E2EHasAuthenticatedChannel { partnerId in
      var result: ObjCBool = false
      try bindingsE2E.hasAuthenticatedChannel(partnerId, ret0_: &result)
      return result.boolValue
    }
  }
}

extension E2EHasAuthenticatedChannel {
  public static let unimplemented = E2EHasAuthenticatedChannel(
    run: XCTUnimplemented("\(Self.self)")
  )
}
