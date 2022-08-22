import XXClient
import XCTestDynamicOverlay

public struct MessengerUD {
  public var get: () -> UserDiscovery?
  public var set: (UserDiscovery?) -> Void

  public func callAsFunction() -> UserDiscovery? {
    get()
  }
}

extension MessengerUD {
  public static func live() -> MessengerUD {
    class Storage { var value: UserDiscovery? }
    let storage = Storage()
    return MessengerUD(
      get: { storage.value },
      set: { storage.value = $0 }
    )
  }
}

extension MessengerUD {
  public static let unimplemented = MessengerUD(
    get: XCTUnimplemented("\(Self.self).get", placeholder: nil),
    set: XCTUnimplemented("\(Self.self).set")
  )
}
