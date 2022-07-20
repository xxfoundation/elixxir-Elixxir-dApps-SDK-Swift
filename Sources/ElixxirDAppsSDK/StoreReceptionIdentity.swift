import Bindings
import XCTestDynamicOverlay

public struct StoreReceptionIdentity {
  public var run: (String, Data, Int) throws -> Bool

  public func callAsFunction(
    key: String,
    identity: Data,
    cmixId: Int
  ) throws -> Bool {
    try run(key, identity, cmixId)
  }
}

extension StoreReceptionIdentity {
  public static let live = StoreReceptionIdentity { key, identity, cmixId in
    var error: NSError?
    let result = BindingsStoreReceptionIdentity(key, identity, cmixId, &error)
    if let error = error {
      throw error
    }
    return result
  }
}

extension StoreReceptionIdentity {
  public static let unimplemented = StoreReceptionIdentity(
    run: XCTUnimplemented("\(Self.self)")
  )
}
