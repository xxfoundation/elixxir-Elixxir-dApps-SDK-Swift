import CustomDump
import XCTest
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels
@testable import AppCore

final class SendGroupMessageTests: XCTestCase {
  enum Action: Equatable {
    case didReceiveError(String)
    case didComplete
    case didSaveMessage(XXModels.Message)
    case didSend(groupId: Data, message: Data, tag: String?)
    case didWaitForRoundResults(roundList: Data, timeoutMS: Int)
    case didUpdateMessage(
      query: XXModels.Message.Query,
      assignments: XXModels.Message.Assignments
    )
  }

  var actions: [Action]!

  override func setUp() {
    actions = []
  }

  override func tearDown() {
    actions = nil
  }

  func testSend() {
    let text = "Hello!"
    let groupId = "group-id".data(using: .utf8)!
    let myContactId = "my-contact-id".data(using: .utf8)!
    let messageId: Int64 = 321
    let sendReport = GroupSendReport(
      rounds: [],
      roundURL: "round-url",
      timestamp: 1234,
      messageId: "message-id".data(using: .utf8)!
    )

    var messageDeliveryCallback: MessageDeliveryCallback?

    var messenger: Messenger = .unimplemented
    messenger.groupChat.get = {
      var groupChat: GroupChat = .unimplemented
      groupChat.send.run = { groupId, message, tag in
        self.actions.append(.didSend(groupId: groupId, message: message, tag: tag))
        return sendReport
      }
      return groupChat
    }
    messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented(Data())
        contact.getIdFromContact.run = { _ in myContactId }
        return contact
      }
      return e2e
    }
    messenger.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.waitForRoundResult.run = { roundList, timeoutMS, callback in
        self.actions.append(.didWaitForRoundResults(roundList: roundList, timeoutMS: timeoutMS))
        messageDeliveryCallback = callback
      }
      return cMix
    }
    var db: DBManagerGetDB = .unimplemented
    db.run = {
      var db: Database = .unimplemented
      db.saveMessage.run = { message in
        self.actions.append(.didSaveMessage(message))
        var message = message
        message.id = messageId
        return message
      }
      db.bulkUpdateMessages.run = { query, assignments in
        self.actions.append(.didUpdateMessage(query: query, assignments: assignments))
        return 1
      }
      return db
    }
    let now = Date()
    let send: SendGroupMessage = .live(
      messenger: messenger,
      db: db,
      now: { now }
    )

    send(
      text: text,
      to: groupId,
      onError: { error in
        self.actions.append(.didReceiveError(error.localizedDescription))
      },
      completion: {
        self.actions.append(.didComplete)
      }
    )

    XCTAssertNoDifference(actions, [
      .didSaveMessage(.init(
        senderId: myContactId,
        recipientId: nil,
        groupId: groupId,
        date: now,
        status: .sending,
        isUnread: false,
        text: text
      )),
      .didSend(
        groupId: groupId,
        message: try! MessagePayload(text: text).encode(),
        tag: nil
      ),
      .didSaveMessage(.init(
        id: messageId,
        networkId: sendReport.messageId,
        senderId: myContactId,
        recipientId: nil,
        groupId: groupId,
        date: now,
        status: .sending,
        isUnread: false,
        text: text,
        roundURL: sendReport.roundURL
      )),
      .didWaitForRoundResults(
        roundList: try! sendReport.encode(),
        timeoutMS: 30_000
      ),
    ])

    actions = []
    messageDeliveryCallback?.handle(.delivered(roundResults: []))

    XCTAssertNoDifference(actions, [
      .didUpdateMessage(
        query: .init(id: [messageId]),
        assignments: .init(status: .sent)
      ),
      .didComplete,
    ])

    actions = []
    messageDeliveryCallback?.handle(.notDelivered(timedOut: true))

    XCTAssertNoDifference(actions, [
      .didUpdateMessage(
        query: .init(id: [messageId]),
        assignments: .init(status: .sendingTimedOut)
      ),
      .didComplete,
    ])

    actions = []
    messageDeliveryCallback?.handle(.notDelivered(timedOut: false))

    XCTAssertNoDifference(actions, [
      .didUpdateMessage(
        query: .init(id: [messageId]),
        assignments: .init(status: .sendingFailed)
      ),
      .didComplete,
    ])
  }

  func testSendDatabaseFailure() {
    struct Failure: Error, Equatable {}
    let failure = Failure()

    var messenger: Messenger = .unimplemented
    messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented(Data())
        contact.getIdFromContact.run = { _ in Data() }
        return contact
      }
      return e2e
    }
    messenger.groupChat.get = { .unimplemented }
    var db: DBManagerGetDB = .unimplemented
    db.run = { throw failure }
    let send: SendGroupMessage = .live(
      messenger: messenger,
      db: db,
      now: XCTestDynamicOverlay.unimplemented("now", placeholder: Date())
    )

    send(
      text: "Hello",
      to: "group-id".data(using: .utf8)!,
      onError: { error in
        self.actions.append(.didReceiveError(error.localizedDescription))
      },
      completion: {
        self.actions.append(.didComplete)
      }
    )

    XCTAssertNoDifference(actions, [
      .didReceiveError(failure.localizedDescription),
      .didComplete
    ])
  }

  func testBulkUpdateOnDeliveryFailure() {
    struct Failure: Error, Equatable {}
    let failure = Failure()

    var messageDeliveryCallback: MessageDeliveryCallback?

    var messenger: Messenger = .unimplemented
    messenger.groupChat.get = {
      var groupChat: GroupChat = .unimplemented
      groupChat.send.run = { _, _, _ in
        GroupSendReport(
          rounds: [],
          roundURL: "",
          timestamp: 0,
          messageId: Data()
        )
      }
      return groupChat
    }
    messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented(Data())
        contact.getIdFromContact.run = { _ in Data() }
        return contact
      }
      return e2e
    }
    messenger.cMix.get = {
      var cMix: CMix = .unimplemented
      cMix.waitForRoundResult.run = { _, _, callback in
        messageDeliveryCallback = callback
      }
      return cMix
    }
    var db: DBManagerGetDB = .unimplemented
    db.run = {
      var db: Database = .unimplemented
      db.saveMessage.run = { message in message }
      db.bulkUpdateMessages.run = { _, _ in throw failure }
      return db
    }
    let now = Date()
    let send: SendGroupMessage = .live(
      messenger: messenger,
      db: db,
      now: { now }
    )

    send(
      text: "Hello",
      to: Data(),
      onError: { error in
        self.actions.append(.didReceiveError(error.localizedDescription))
      },
      completion: {
        self.actions.append(.didComplete)
      }
    )

    messageDeliveryCallback?.handle(.delivered(roundResults: []))

    XCTAssertNoDifference(actions, [
      .didReceiveError(failure.localizedDescription),
      .didComplete,
    ])
  }
}
