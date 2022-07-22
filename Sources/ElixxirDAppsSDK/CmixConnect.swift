import Bindings
import XCTestDynamicOverlay

public struct CmixConnect {
  public var run: (Bool, Int, Data, Data) throws -> Connection

  public func callAsFunction(
    withAuthentication: Bool,
    e2eId: Int,
    recipientContact: Data,
    e2eParamsJSON: Data
  ) throws -> Connection {
    try run(withAuthentication, e2eId, recipientContact, e2eParamsJSON)
  }
}

extension CmixConnect {
  public static func live(_ bindingsCmix: BindingsCmix) -> CmixConnect {
    CmixConnect { withAuthentication, e2eId, recipientContact, e2eParamsJSON in
      if withAuthentication {
        return .live(try bindingsCmix.connect(
          withAuthentication: e2eId,
          recipientContact: recipientContact,
          e2eParamsJSON: e2eParamsJSON
        ))
      } else {
        return .live(try bindingsCmix.connect(
          e2eId,
          recipientContact: recipientContact,
          e2eParamsJSON: e2eParamsJSON
        ))
      }
    }
  }
}

extension CmixConnect {
  public static let unimplemented = CmixConnect(
    run: XCTUnimplemented("\(Self.self)")
  )
}
