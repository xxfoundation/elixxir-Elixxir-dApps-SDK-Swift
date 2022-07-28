import Bindings
import XCTestDynamicOverlay

public struct LoadOrNewUserDiscovery {
  public var run: (Int, UdNetworkStatus, String, Data) throws -> UserDiscovery

  public func callAsFunction(
    e2eId: Int,
    follower: UdNetworkStatus,
    username: String,
    registrationValidationSignature: Data
  ) throws -> UserDiscovery {
    try run(e2eId, follower, username, registrationValidationSignature)
  }
}

extension LoadOrNewUserDiscovery {
  public static let live = LoadOrNewUserDiscovery {
    e2eId, follower, username, registrationValidationSignature in

    var error: NSError?
    let bindingsUD = BindingsLoadOrNewUserDiscovery(
      e2eId,
      follower.makeBindingsUdNetworkStatus(),
      username,
      registrationValidationSignature,
      &error
    )
    if let error = error {
      throw error
    }
    guard let bindingsUD = bindingsUD else {
      fatalError("BindingsLoadOrNewUserDiscovery returned `nil` without providing error")
    }
    return .live(bindingsUD)
  }
}

extension LoadOrNewUserDiscovery {
  public static let unimplemented = LoadOrNewUserDiscovery(
    run: XCTUnimplemented("\(Self.self)")
  )
}
