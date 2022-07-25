import Bindings
import XCTestDynamicOverlay

public struct SetFactsOnContact {
  public var run: (Data, [Fact]) throws -> Data

  public func callAsFunction(
    contact: Data,
    facts: [Fact]
  ) throws -> Data {
    try run(contact, facts)
  }
}

extension SetFactsOnContact {
  public static let live = SetFactsOnContact { contact, facts in
    let factsData = try facts.encode()
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

extension SetFactsOnContact {
  public static let unimplemented = SetFactsOnContact(
    run: XCTUnimplemented("\(Self.self)")
  )
}
