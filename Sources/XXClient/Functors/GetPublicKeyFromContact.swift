import Bindings
import XCTestDynamicOverlay

public struct GetPublicKeyFromContact {
  public var run: (Data) throws -> Data

  public func callAsFunction(contact: Data) throws -> Data {
    try run(contact)
  }
}

extension GetPublicKeyFromContact {
  public static let live = GetPublicKeyFromContact { contact in
    var error: NSError?
    let key = BindingsGetPubkeyFromContact(contact, &error)
    if let error = error {
      throw error
    }
    guard let key = key else {
      fatalError("BindingsGetPubkeyFromContact returned `nil` without providing error")
    }
    return key
  }
}

extension GetPublicKeyFromContact {
  public static let unimplemented = GetPublicKeyFromContact(
    run: XCTUnimplemented("\(Self.self)")
  )
}
