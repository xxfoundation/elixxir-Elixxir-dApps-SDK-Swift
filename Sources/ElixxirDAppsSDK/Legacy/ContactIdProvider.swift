import Bindings

public struct ContactIdProvider {
  public var get: (Data) throws -> Data

  public func callAsFunction(contact: Data) throws -> Data {
    try get(contact)
  }
}

extension ContactIdProvider {
  public static let live = ContactIdProvider { contact in
    var error: NSError?
    let id = BindingsGetIDFromContact(contact, &error)
    if let error = error {
      throw error
    }
    guard let id = id else {
      fatalError("BindingsGetIDFromContact returned `nil` without providing error")
    }
    return id
  }
}

#if DEBUG
extension ContactIdProvider {
  public static let failing = ContactIdProvider { _ in
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
