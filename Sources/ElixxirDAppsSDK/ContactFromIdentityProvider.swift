import Bindings

public struct ContactFromIdentityProvider {
  public var get: (Identity) throws -> Data

  public func callAsFunction(identity: Identity) throws -> Data {
    try get(identity)
  }
}

extension ContactFromIdentityProvider {
  public static func live(bindingsClient: BindingsClient) -> ContactFromIdentityProvider {
    ContactFromIdentityProvider { identity in
      let encoder = JSONEncoder()
      let identityData = try encoder.encode(identity)
      let contactData = try bindingsClient.getContactFromIdentity(identityData)
      return contactData
    }
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
