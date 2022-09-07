import Foundation
import XXClient
import XCTestDynamicOverlay

public struct MessengerRegisterForNotifications {
  public enum Error: Swift.Error, Equatable {
    case notConnected
  }

  public var run: (Data) throws -> Void

  public func callAsFunction(token: Data) throws -> Void {
    try run(token)
  }
}

extension MessengerRegisterForNotifications {
  public static func live(_ env: MessengerEnvironment) -> MessengerRegisterForNotifications {
    MessengerRegisterForNotifications { token in
      guard let e2e = env.e2e() else {
        throw Error.notConnected
      }
      try env.registerForNotifications(
        e2eId: e2e.getId(),
        token: token.map { String(format: "%02hhx", $0) }.joined()
      )
    }
  }
}

extension MessengerRegisterForNotifications {
  public static let unimplemented = MessengerRegisterForNotifications(
    run: XCTUnimplemented("\(Self.self)")
  )
}
