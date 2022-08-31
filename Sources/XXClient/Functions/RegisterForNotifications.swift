import Bindings
import XCTestDynamicOverlay

public struct RegisterForNotifications {
  public var run: (Int, String) throws -> Void

  public func callAsFunction(
    e2eId: Int,
    token: String
  ) throws {
    try run(e2eId, token)
  }
}

extension RegisterForNotifications {
  public static let live = RegisterForNotifications { e2eId, token in
    var error: NSError?
    BindingsRegisterForNotifications(e2eId, token, &error)
    if let error = error {
      throw error
    }
  }
}

extension RegisterForNotifications {
  public static let unimplemented = RegisterForNotifications(
    run: XCTUnimplemented("\(Self.self)")
  )
}
