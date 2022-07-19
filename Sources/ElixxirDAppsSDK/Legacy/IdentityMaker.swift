import Bindings

public struct IdentityMaker {
  public var make: () throws -> Identity

  public func callAsFunction() throws -> Identity {
    try make()
  }
}

extension IdentityMaker {
  public static func live(bindingsClient: BindingsCmix) -> IdentityMaker {
    IdentityMaker {
      let data = try bindingsClient.makeIdentity()
      let decoder = JSONDecoder()
      return try decoder.decode(Identity.self, from: data)
    }
  }
}

#if DEBUG
extension IdentityMaker {
  public static let failing = IdentityMaker {
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
