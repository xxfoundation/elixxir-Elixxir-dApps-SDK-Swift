import XXModels
import XXClient
import Foundation
import XXMessengerClient
import XCTestDynamicOverlay

public struct GroupMessageHandler {
  public typealias OnError = (Error) -> Void

  public var run: (@escaping OnError) -> Cancellable

  public func callAsFunction(onError: @escaping OnError) -> Cancellable {
    run(onError)
  }
}

extension GroupMessageHandler {
  public static func live(
    messenger: Messenger,
    db: DBManagerGetDB
  ) -> GroupMessageHandler {
    GroupMessageHandler { onError in
      messenger.registerGroupChatProcessor(.init { result in
        switch result {
        case .success(let callback):
          do {
            let payload = try MessagePayload.decode(callback.decryptedMessage.payload)
            try db().saveMessage(.init(
              networkId: callback.decryptedMessage.messageId,
              senderId: callback.decryptedMessage.senderId,
              recipientId: nil,
              groupId: callback.decryptedMessage.groupId,
              date: Date(timeIntervalSince1970: TimeInterval(callback.decryptedMessage.timestamp) / 1_000_000_000),
              status: .received,
              isUnread: true,
              text: payload.text,
              replyMessageId: payload.replyingTo,
              roundURL: callback.roundUrl
            ))
          } catch {
            onError(error)
          }
        case .failure(let error):
          onError(error)
        }
      })
    }
  }
}

extension GroupMessageHandler {
  public static let unimplemented = GroupMessageHandler(
    run: XCTestDynamicOverlay.unimplemented("\(Self.self)", placeholder: Cancellable {})
  )
}
