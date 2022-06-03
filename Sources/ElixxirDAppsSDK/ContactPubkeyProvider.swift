import Bindings

public struct ContactPubkeyProvider {
  public var get: (Data) throws -> Data

  public func callAsFunction(contact: Data) throws -> Data {
    try get(contact)
  }
}

extension ContactPubkeyProvider {
  public static let live = ContactPubkeyProvider { contact in
    var error: NSError?
    let pubkey = BindingsGetPubkeyFromContact(contact, &error)
    if let error = error {
      throw error
    }
    guard let pubkey = pubkey else {
      fatalError("BindingsGetPubkeyFromContact returned `nil` without providing error")
    }
    return pubkey
  }
}

#if DEBUG
extension ContactPubkeyProvider {
  public static let failing = ContactPubkeyProvider { _ in
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
