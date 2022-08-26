import Bindings
import XCTestDynamicOverlay

public struct GetIdFromContact {
  public var run: (Data) throws -> Data

  public func callAsFunction(_ contactData: Data) throws -> Data {
    try run(contactData)
  }
}

extension GetIdFromContact {
  public static let live = GetIdFromContact { contactData in
    var error: NSError?
    let id = BindingsGetIDFromContact(contactData, &error)
    if let error = error {
      throw error
    }
    guard let id = id else {
      fatalError("BindingsGetIDFromContact returned `nil` without providing error")
    }
    return id
  }
}

extension GetIdFromContact {
  public static let unimplemented = GetIdFromContact(
    run: XCTUnimplemented("\(Self.self)")
  )
}
