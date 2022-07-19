import Bindings

public struct ContactFromIdentityProvider {
  public var get: () throws -> Data

  public func callAsFunction() throws -> Data {
    try get()
  }
}

extension ContactFromIdentityProvider {
  public static func live(bindingsClientE2E: BindingsE2e) -> ContactFromIdentityProvider {
    ContactFromIdentityProvider {
      let contactData = bindingsClientE2E.getContact()
        guard let contactData = contactData else {
            fatalError("BindingsGetContact returned `nil` without providing error")
        }
      return contactData
    }
  }
}

#if DEBUG
extension ContactFromIdentityProvider {
  public static let failing = ContactFromIdentityProvider {
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
