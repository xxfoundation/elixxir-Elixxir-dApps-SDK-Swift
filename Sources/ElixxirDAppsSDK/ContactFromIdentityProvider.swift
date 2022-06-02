import Bindings

public struct ContactFromIdentityProvider {
  public var get: (Data) throws -> Data

  public func callAsFunction(identity: Data) throws -> Data {
    try get(identity)
  }
}

extension ContactFromIdentityProvider {
  public static func live(bindingsClient: BindingsClient) -> ContactFromIdentityProvider {
    ContactFromIdentityProvider(get: bindingsClient.getContactFromIdentity(_:))
  }
}

#if DEBUG
extension ContactFromIdentityProvider {
  public static let failing = ContactFromIdentityProvider { _ in
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
