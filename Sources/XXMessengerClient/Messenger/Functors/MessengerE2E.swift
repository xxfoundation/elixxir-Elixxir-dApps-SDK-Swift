import XXClient
import XCTestDynamicOverlay

public struct MessengerE2E {
  public var get: () -> E2E?
  public var set: (E2E?) -> Void

  public func callAsFunction() -> E2E? {
    get()
  }
}

extension MessengerE2E {
  public static func live() -> MessengerE2E {
    class Storage { var value: E2E? }
    let storage = Storage()
    return MessengerE2E(
      get: { storage.value },
      set: { storage.value = $0 }
    )
  }
}

extension MessengerE2E {
  public static let unimplemented = MessengerE2E(
    get: XCTUnimplemented("\(Self.self).get", placeholder: nil),
    set: XCTUnimplemented("\(Self.self).set")
  )
}
