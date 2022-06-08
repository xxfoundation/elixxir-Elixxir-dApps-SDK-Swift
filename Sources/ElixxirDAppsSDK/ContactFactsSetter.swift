import Bindings

public struct ContactFactsSetter {
  public var set: (Data, [Fact]) throws -> Data

  public func callAsFunction(
    contact: Data,
    facts: [Fact]
  ) throws -> Data {
    try set(contact, facts)
  }
}

extension ContactFactsSetter {
  public static let live = ContactFactsSetter { contact, facts in
    let encoder = JSONEncoder()
    let factsData = try encoder.encode(facts)
    var error: NSError?
    let updatedContact = BindingsSetFactsOnContact(contact, factsData, &error)
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
