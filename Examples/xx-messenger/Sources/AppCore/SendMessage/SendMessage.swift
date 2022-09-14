import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct SendMessage {
  public typealias OnError = (Error) -> Void
  public typealias Completion = () -> Void

  public var run: (String, Data, @escaping OnError, @escaping Completion) -> Void

  public func callAsFunction(
    text: String,
    to recipientId: Data,
    onError: @escaping OnError,
    completion: @escaping Completion
  ) {
    run(text, recipientId, onError, completion)
  }
}

extension SendMessage {
  public static func live(
    messenger: Messenger,
    db: DBManagerGetDB,
    now: @escaping () -> Date
  ) -> SendMessage {
    SendMessage { text, recipientId, onError, completion in
      do {
        let myContactId = try messenger.e2e.tryGet().getContact().getId()
        let message = try db().saveMessage(.init(
          senderId: myContactId,
          recipientId: recipientId,
          groupId: nil,
          date: now(),
          status: .sending,
          isUnread: false,
          text: text
        ))
        let payload = MessagePayload(text: message.text)
        let report = try messenger.sendMessage(
          recipientId: recipientId,
          payload: try payload.encode(),
          deliveryCallback: { deliveryReport in
            let status: XXModels.Message.Status
            switch deliveryReport.result {
            case .delivered:
              status = .sent
            case .notDelivered(let timedOut):
              status = timedOut ? .sendingTimedOut : .sendingFailed
            case .failure(let error):
              status = .sendingFailed
              onError(error)
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
        if var message = try db().fetchMessages(.init(id: [message.id])).first {
          message.networkId = report.messageId
          message.roundURL = report.roundURL
          _ = try db().saveMessage(message)
        }
      } catch {
        onError(error)
        completion()
      }
    }
  }
}

extension SendMessage {
  public static let unimplemented = SendMessage(
    run: XCTUnimplemented("\(Self.self)")
  )
}
