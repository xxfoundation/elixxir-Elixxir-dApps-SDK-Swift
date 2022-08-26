import Bindings
import XCTestDynamicOverlay

public struct GetFactsFromContact {
  public var run: (Data) throws -> [Fact]

  public func callAsFunction(_ contactData: Data) throws -> [Fact] {
    try run(contactData)
  }
}

extension GetFactsFromContact {
  public static let live = GetFactsFromContact { contactData in
    var error: NSError?
    let data = BindingsGetFactsFromContact(contactData, &error)
    if let error = error {
      throw error
    }
    guard let data = data else {
      fatalError("BindingsGetFactsFromContact returned `nil` without providing error")
    }
    return try [Fact].decode(data)
  }
}

extension GetFactsFromContact {
  public static let unimplemented = GetFactsFromContact(
    run: XCTUnimplemented("\(Self.self)")
  )
}
