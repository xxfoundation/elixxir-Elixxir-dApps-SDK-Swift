import Bindings
import XCTestDynamicOverlay

public struct CMixConnect {
  public var run: (Bool, Int, Contact, Data) throws -> Connection

  public func callAsFunction(
    withAuthentication: Bool,
    e2eId: Int,
    recipient: Contact,
    e2eParamsJSON: Data = GetE2EParams.liveDefault()
  ) throws -> Connection {
    try run(withAuthentication, e2eId, recipient, e2eParamsJSON)
  }
}

extension CMixConnect {
  public static func live(_ bindingsCMix: BindingsCmix) -> CMixConnect {
    CMixConnect { withAuthentication, e2eId, recipient, e2eParamsJSON in
      if withAuthentication {
        return .live(try bindingsCMix.connect(
          withAuthentication: e2eId,
          recipientContact: recipient.data,
          e2eParamsJSON: e2eParamsJSON
        ))
      } else {
        return .live(try bindingsCMix.connect(
          e2eId,
          recipientContact: recipient.data,
          e2eParamsJSON: e2eParamsJSON
        ))
      }
    }
  }
}

extension CMixConnect {
  public static let unimplemented = CMixConnect(
    run: XCTUnimplemented("\(Self.self)")
  )
}
