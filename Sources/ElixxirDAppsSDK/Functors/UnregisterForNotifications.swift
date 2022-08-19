import Bindings
import XCTestDynamicOverlay

public struct UnregisterForNotifications {
  public var run: (Int) throws -> Void

  public func callAsFunction(
    e2eId: Int
  ) throws {
    try run(e2eId)
  }
}

extension UnregisterForNotifications {
  public static let live = UnregisterForNotifications { e2eId in
    var error: NSError?
    BindingsUnregisterForNotifications(e2eId, &error)
    if let error = error {
      throw error
    }
  }
}

extension UnregisterForNotifications {
  public static let unimplemented = UnregisterForNotifications(
    run: XCTUnimplemented("\(Self.self)")
  )
}

