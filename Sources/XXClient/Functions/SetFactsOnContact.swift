import Bindings
import XCTestDynamicOverlay

public struct SetFactsOnContact {
  public var run: (Data, [Fact]) throws -> Data

  public func callAsFunction(
    contactData: Data,
    facts: [Fact]
  ) throws -> Data {
    try run(contactData, facts)
  }
}

extension SetFactsOnContact {
  public static let live = SetFactsOnContact { contactData, facts in
    let factsData = try facts.encode()
    var error: NSError?
    let updatedContactData = BindingsSetFactsOnContact(contactData, factsData, &error)
    if let error = error {
      throw error
    }
    guard let updatedContactData = updatedContactData else {
      fatalError("BindingsSetFactsOnContact returned `nil` without providing error")
    }
    return updatedContactData
  }
}

extension SetFactsOnContact {
  public static let unimplemented = SetFactsOnContact(
    run: XCTUnimplemented("\(Self.self)")
  )
}
