import Bindings
import XCTestDynamicOverlay

public struct LoadReceptionIdentity {
  public var run: (String, Int) throws -> ReceptionIdentity

  public func callAsFunction(
    key: String,
    cmixId: Int
  ) throws -> ReceptionIdentity {
    try run(key, cmixId)
  }
}

extension LoadReceptionIdentity {
  public static let live = LoadReceptionIdentity { key, cmixId in
    var error: NSError?
    let data = BindingsLoadReceptionIdentity(key, cmixId, &error)
    if let error = error {
      throw error
    }
    guard let data = data else {
      fatalError("BindingsLoadReceptionIdentity returned `nil` without providing error")
    }
    return try ReceptionIdentity.decode(data)
  }
}

extension LoadReceptionIdentity {
  public static let unimplemented = LoadReceptionIdentity(
    run: XCTUnimplemented("\(Self.self)")
  )
}
