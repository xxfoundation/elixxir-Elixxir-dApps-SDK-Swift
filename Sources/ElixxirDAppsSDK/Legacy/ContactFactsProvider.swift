import Bindings

public struct ContactFactsProvider {
  public var get: (Data) throws -> [Fact]

  public func callAsFunction(contact: Data) throws -> [Fact] {
    try get(contact)
  }
}

extension ContactFactsProvider {
  public static let live = ContactFactsProvider { contact in
    var error: NSError?
    let factsData = BindingsGetFactsFromContact(contact, &error)
    if let error = error {
      throw error
    }
    guard let factsData = factsData else {
      fatalError("BindingsGetFactsFromContact returned `nil` without providing error")
    }
    let decoder = JSONDecoder()
    let facts = try decoder.decode([Fact].self, from: factsData)
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
