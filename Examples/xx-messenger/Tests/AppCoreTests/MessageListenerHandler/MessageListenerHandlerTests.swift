import CustomDump
import XCTest
import XXClient
import XXMessengerClient
import XXModels
@testable import AppCore

final class MessageListenerHandlerTests: XCTestCase {
  func testHandleIncomingMessage() throws {
    var didRegisterListener: [Listener] = []
    var didCancelListener = 0
    var didSaveMessage: [XXModels.Message] = []

    var messenger: Messenger = .unimplemented
    messenger.registerMessageListener.run = { listener in
      didRegisterListener.append(listener)
      return Cancellable { didCancelListener += 1 }
    }
    var db: DBManagerGetDB = .unimplemented
    db.run = {
      var db: Database = .unimplemented
      db.saveMessage.run = { message in
        didSaveMessage.append(message)
        return message
      }
      return db
    }
    let handler: MessageListenerHandler = .live(
      messenger: messenger,
      db: db
    )

    var cancellable: Cancellable? = handler(onError: { _ in XCTFail() })

    XCTAssertNoDifference(didRegisterListener.count, 1)

    let payload = MessagePayload(text: "Hello")
    let xxMessage = XXClient.Message(
      messageType: 111,
      id: "message-id".data(using: .utf8)!,
      payload: try! payload.encode(),
      sender: "sender-id".data(using: .utf8)!,
      recipientId: "recipient-id".data(using: .utf8)!,
      ephemeralId: 222,
      timestamp: 1_653_580_439_357_351_000,
      encrypted: true,
      roundId: 333,
      roundURL: "round-url"
    )
    didRegisterListener.first?.handle(xxMessage)

    XCTAssertNoDifference(didSaveMessage, [
      .init(
        networkId: xxMessage.id,
        senderId: xxMessage.sender,
        recipientId: xxMessage.recipientId,
        groupId: nil,
        date: Date(timeIntervalSince1970: TimeInterval(xxMessage.timestamp) / 1_000_000_000),
        status: .received,
        isUnread: true,
        text: payload.text,
        roundURL: xxMessage.roundURL
      )
    ])

    cancellable = nil
    _ = cancellable

    XCTAssertNoDifference(didCancelListener, 1)
  }

  func testDatabaseFailure() {
    struct Failure: Error, Equatable {}
    let error = Failure()
    var registeredListeners: [Listener] = []
    var didReceiveError: [Error] = []

    var messenger: Messenger = .unimplemented
    messenger.registerMessageListener.run = { listener in
      registeredListeners.append(listener)
      return Cancellable {}
    }
    var db: DBManagerGetDB = .unimplemented
    db.run = { throw error }
    let handler: MessageListenerHandler = .live(
      messenger: messenger,
      db: db
    )

    _ = handler(onError: { error in didReceiveError.append(error) })

    let payload = MessagePayload(text: "Hello")
    let xxMessage = XXClient.Message(
      messageType: 111,
      id: "message-id".data(using: .utf8)!,
      payload: try! payload.encode(),
      sender: "sender-id".data(using: .utf8)!,
      recipientId: "recipient-id".data(using: .utf8)!,
      ephemeralId: 222,
      timestamp: 1_653_580_439_357_351_000,
      encrypted: true,
      roundId: 333,
      roundURL: "round-url"
    )
    registeredListeners.first?.handle(xxMessage)

    XCTAssertNoDifference(didReceiveError.count, 1)
    XCTAssertNoDifference(didReceiveError.first as? Failure, error)
  }
}
