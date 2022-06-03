import Bindings

public struct ContactFactsProvider {
  public var get: (Data) throws -> Data

  public func callAsFunction(contact: Data) throws -> Data {
    try get(contact)
  }
}

extension ContactFactsProvider {
  public static let live = ContactFactsProvider { contact in
    var error: NSError?
    let facts = BindingsGetFactsFromContact(contact, &error)
    if let error = error {
      throw error
    }
    guard let facts = facts else {
      fatalError("BindingsGetFactsFromContact returned `nil` without providing error")
    }
    return facts
  }
}

#if DEBUG
extension ContactFactsProvider {
  public static let failing = ContactFactsProvider { _ in
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
