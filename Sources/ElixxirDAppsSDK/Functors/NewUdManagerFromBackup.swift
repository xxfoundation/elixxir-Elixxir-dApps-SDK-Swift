import Bindings
import XCTestDynamicOverlay

public struct NewUdManagerFromBackup {
  public var run: (Int, UdNetworkStatus, Fact?, Fact?) throws -> UserDiscovery

  public func callAsFunction(
    e2eId: Int,
    follower: UdNetworkStatus,
    email: Fact?,
    phone: Fact?
  ) throws -> UserDiscovery {
    try run(e2eId, follower, email, phone)
  }
}

extension NewUdManagerFromBackup {
  public static let live = NewUdManagerFromBackup {
    e2eId, follower, email, phone in

    var error: NSError?
    let bindingsUD = BindingsNewUdManagerFromBackup(
      e2eId,
      follower.makeBindingsUdNetworkStatus(),
      try email?.encode(),
      try phone?.encode(),
      &error
    )
    if let error = error {
      throw error
    }
    guard let bindingsUD = bindingsUD else {
      fatalError("BindingsNewUdManagerFromBackup returned `nil` without providing error")
    }
    return .live(bindingsUD)
  }
}

extension NewUdManagerFromBackup {
  public static let unimplemented = NewUdManagerFromBackup(
    run: XCTUnimplemented("\(Self.self)")
  )
}
