import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct MessageListenerHandler {
  public typealias OnError = (Error) -> Void

  public var run: (@escaping OnError) -> Cancellable

  public func callAsFunction(onError: @escaping OnError) -> Cancellable {
    run(onError)
  }
}

extension MessageListenerHandler {
  public static func live(
    messenger: Messenger,
    db: DBManagerGetDB
  ) -> MessageListenerHandler {
    MessageListenerHandler { onError in
      let listener = Listener { message in
        do {
          let payload = try MessagePayload.decode(message.payload)
          try db().saveMessage(.init(
            networkId: message.id,
            senderId: message.sender,
            recipientId: message.recipientId,
            groupId: nil,
            date: Date(timeIntervalSince1970: TimeInterval(message.timestamp) / 1_000_000_000),
            status: .received,
            isUnread: true,
            text: payload.text,
            roundURL: message.roundURL
          ))
        } catch {
          onError(error)
        }
      }
      return messenger.registerMessageListener(listener)
    }
  }
}

extension MessageListenerHandler {
  public static let unimplemented = MessageListenerHandler(
    run: XCTUnimplemented("\(Self.self)", placeholder: Cancellable {})
  )
}
