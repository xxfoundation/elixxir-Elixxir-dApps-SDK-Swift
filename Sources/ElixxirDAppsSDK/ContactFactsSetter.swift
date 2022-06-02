import Bindings

public struct ContactFactsSetter {
  public var set: (Data, Data) throws -> Data

  public func callAsFunction(contact: Data, facts: Data) throws -> Data {
    try set(contact, facts)
  }
}

extension ContactFactsSetter {
  public static let live = ContactFactsSetter { contact, facts in
    var error: NSError?
    let updatedContact = BindingsSetFactsOnContact(contact, facts, &error)
    if let error = error {
      throw error
    }
    guard let updatedContact = updatedContact else {
      fatalError("BindingsSetFactsOnContact returned `nil` without providing error")
    }
    return updatedContact
  }
}

#if DEBUG
extension ContactFactsSetter {
  public static let failing = ContactFactsSetter { _, _ in
    struct NotImplemented: Error {}
    throw NotImplemented()
  }
}
#endif
