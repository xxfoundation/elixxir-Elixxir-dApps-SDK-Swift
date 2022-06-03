import Bindings

public struct IdentityMaker {
  public var make: () throws -> Data

  public func callAsFunction() throws -> Data {
    try make()
  }
}

extension IdentityMaker {
  public static func live(bindingsClient: BindingsClient) -> IdentityMaker {
    IdentityMaker {
      try bindingsClient.makeIdentity()
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
