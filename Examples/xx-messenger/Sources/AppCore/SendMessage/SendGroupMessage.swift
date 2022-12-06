import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct SendGroupMessage {
  public typealias OnError = (Error) -> Void
  public typealias Completion = () -> Void

  public var run: (String, Data, @escaping OnError, @escaping Completion) -> Void

  public func callAsFunction(
    text: String,
    to groupId: Data,
    onError: @escaping OnError,
    completion: @escaping Completion
  ) {
    run(text, groupId, onError, completion)
  }
}

extension SendGroupMessage {
  public static func live(
    messenger: Messenger,
    db: DBManagerGetDB,
    now: @escaping () -> Date
  ) -> SendGroupMessage {
    SendGroupMessage { text, groupId, onError, completion in
      do {
        let chat = try messenger.groupChat.tryGet()
        let myContactId = try messenger.e2e.tryGet().getContact().getId()
        var message = try db().saveMessage(.init(
          senderId: myContactId,
          recipientId: nil,
          groupId: groupId,
          date: now(),
          status: .sending,
          isUnread: false,
          text: text
        ))
        let payload = MessagePayload(text: message.text)
        let report = try chat.send(
          groupId: groupId,
          message: try payload.encode()
        )
        message.networkId = report.messageId
        message.roundURL = report.roundURL
        message = try db().saveMessage(message)
        try messenger.cMix.tryGet().waitForRoundResult(
          roundList: try report.encode(),
          timeoutMS: 30_000,
          callback: .init { result in
            let status: XXModels.Message.Status
            switch result {
            case .delivered(_):
              status = .sent
            case .notDelivered(let timedOut):
              status = timedOut ? .sendingTimedOut : .sendingFailed
            }
            do {
              try db().bulkUpdateMessages(
                .init(id: [message.id]),
                .init(status: status)
              )
            } catch {
              onError(error)
            }
            completion()
          }
        )
      } catch {
        onError(error)
        completion()
      }
    }
  }
}

extension SendGroupMessage {
  public static let unimplemented = SendGroupMessage(
    run: XCTUnimplemented("\(Self.self)")
  )
}
