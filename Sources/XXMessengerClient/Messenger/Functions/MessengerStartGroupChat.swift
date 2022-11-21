import XXClient
import XCTestDynamicOverlay

public struct MessengerStartGroupChat {
  public enum Error: Swift.Error, Equatable {
    case notConnected
  }

  public var run: () throws -> Void

  public func callAsFunction() throws {
    try run()
  }
}

extension MessengerStartGroupChat {
  public static func live(_ env: MessengerEnvironment) -> MessengerStartGroupChat {
    MessengerStartGroupChat {
      guard let e2e = env.e2e.get() else {
        throw Error.notConnected
      }
      let groupChat = try env.newGroupChat(
        e2eId: e2e.getId(),
        groupRequest: env.groupRequests.registered(),
        groupChatProcessor: env.groupChatProcessors.registered()
      )
      env.groupChat.set(groupChat)
    }
  }
}

extension MessengerStartGroupChat {
  public static let unimplemented = MessengerStartGroupChat(
    run: XCTestDynamicOverlay.unimplemented("\(Self.self)")
  )
}
