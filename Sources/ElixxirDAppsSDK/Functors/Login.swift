import Bindings
import XCTestDynamicOverlay

public struct Login {
  public var run: (Bool, Int, AuthCallbacks?, ReceptionIdentity, Data) throws -> E2E

  public func callAsFunction(
    ephemeral: Bool = false,
    cmixId: Int,
    authCallbacks: AuthCallbacks? = nil,
    identity: ReceptionIdentity,
    e2eParamsJSON: Data
  ) throws -> E2E {
    try run(ephemeral, cmixId, authCallbacks, identity, e2eParamsJSON)
  }
}

extension Login {
  public static let live = Login { ephemeral, cmixId, authCallbacks, identity, e2eParamsJSON in
    var error: NSError?
    let bindingsE2E: BindingsE2e?
    if ephemeral {
      bindingsE2E = BindingsLogin(
        cmixId,
        authCallbacks?.makeBindingsAuthCallbacks(),
        try identity.encode(),
        e2eParamsJSON,
        &error
      )
    } else {
      bindingsE2E = BindingsLoginEphemeral(
        cmixId,
        authCallbacks?.makeBindingsAuthCallbacks(),
        try identity.encode(),
        e2eParamsJSON,
        &error
      )
    }
    if let error = error {
      throw error
    }
    guard let bindingsE2E = bindingsE2E else {
      let functionName = "BindingsLogin\(ephemeral ? "Ephemeral" : "")"
      fatalError("\(functionName) returned `nil` without providing error")
    }
    return .live(bindingsE2E)
  }
}

extension Login {
  public static let unimplemented = Login(
    run: XCTUnimplemented("\(Self.self)")
  )
}
