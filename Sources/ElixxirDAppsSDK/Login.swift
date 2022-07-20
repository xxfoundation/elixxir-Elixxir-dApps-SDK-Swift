import Bindings
import XCTestDynamicOverlay

public struct Login {
  public var run: (Int, Data, Data) throws -> E2E

  public func callAsFunction(
    cmixId: Int,
    identity: Data,
    e2eParamsJSON: Data
  ) throws -> E2E {
    try run(cmixId, identity, e2eParamsJSON)
  }
}

extension Login {
  public static let live = Login { cmixId, identity, e2eParamsJSON in
    var error: NSError?
    let bindingsE2E = BindingsLogin(
      cmixId,
      nil, // TODO: pass callbacks
      identity,
      e2eParamsJSON,
      &error
    )
    if let error = error {
      throw error
    }
    guard let bindingsE2E = bindingsE2E else {
      fatalError("BindingsLogin returned `nil` without providing error")
    }
    return .live(bindingsE2E)
  }
}

extension Login {
  public static let unimplemented = Login(
    run: XCTUnimplemented("\(Self.self)")
  )
}
