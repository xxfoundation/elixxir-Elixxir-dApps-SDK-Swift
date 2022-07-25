import Bindings

public struct E2E {
  public var getId: E2EGetId
  public var getReceptionId: E2EGetReceptionId

  // TODO:
}

extension E2E {
  public static func live(_ bindingsE2E: BindingsE2e) -> E2E {
    E2E(
      getId: .live(bindingsE2E: bindingsE2E),
      getReceptionId: .live(bindingsE2E: bindingsE2E)
    )
  }
}

extension E2E {
  public static let unimplemented = E2E(
    getId: .unimplemented,
    getReceptionId: .unimplemented
  )
}
