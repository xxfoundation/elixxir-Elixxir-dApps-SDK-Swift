import CustomDump
import XCTest
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels
@testable import AppCore

final class SendMessageTests: XCTestCase {
  func testSend() {
    struct MessengerSendMessageParams: Equatable {
      var recipientId: Data
      var payload: Data
    }
    struct MessageBulkUpdate: Equatable {
      var query: XXModels.Message.Query
      var assignments: XXModels.Message.Assignments
    }

    var messengerDidSendMessageWithParams: [MessengerSendMessageParams] = []
    var messengerDidSendMessageWithDeliveryCallback: [MessengerSendMessage.DeliveryCallback?] = []
    var dbDidSaveMessage: [XXModels.Message] = []
    var dbDidFetchMessagesWithQuery: [XXModels.Message.Query] = []
    var dbDidBulkUpdateMessages: [MessageBulkUpdate] = []
    var didReceiveError: [Error] = []
    var didComplete = 0

    let myContactId = "my-contact-id".data(using: .utf8)!
    let text = "Hello"
    let recipientId = "recipient-id".data(using: .utf8)!
    let messageId: Int64 = 123
    let sendReport = E2ESendReport(
      rounds: [],
      roundURL: "round-url",
      messageId: "message-id".data(using: .utf8)!,
      timestamp: 0,
      keyResidue: Data()
    )
    var dbFetchMessagesResult: [XXModels.Message] = []

    var messenger: Messenger = .unimplemented
    messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented(Data())
        contact.getIdFromContact.run = { _ in myContactId }
        return contact
      }
      return e2e
    }
    messenger.sendMessage.run = { recipientId, payload, deliveryCallback in
      messengerDidSendMessageWithParams.append(.init(recipientId: recipientId, payload: payload))
      messengerDidSendMessageWithDeliveryCallback.append(deliveryCallback)
      return sendReport
    }
    var db: DBManagerGetDB = .unimplemented
    db.run = {
      var db: Database = .failing
      db.saveMessage.run = { message in
        dbDidSaveMessage.append(message)
        var message = message
        message.id = messageId
        dbFetchMessagesResult = [message]
        return message
      }
      db.fetchMessages.run = { query in
        dbDidFetchMessagesWithQuery.append(query)
        return dbFetchMessagesResult
      }
      db.bulkUpdateMessages.run = { query, assignments in
        dbDidBulkUpdateMessages.append(.init(query: query, assignments: assignments))
        return 0
      }
      return db
    }
    let now = Date()
    let send: SendMessage = .live(
      messenger: messenger,
      db: db,
      now: { now }
    )

    send(
      text: text,
      to: recipientId,
      onError: { error in didReceiveError.append(error) },
      completion: { didComplete += 1 }
    )

    XCTAssertNoDifference(dbDidSaveMessage, [
      .init(
        senderId: myContactId,
        recipientId: recipientId,
        groupId: nil,
        date: now,
        status: .sending,
        isUnread: false,
        text: text
      ),
      .init(
        id: messageId,
        networkId: sendReport.messageId!,
        senderId: myContactId,
        recipientId: recipientId,
        groupId: nil,
        date: now,
        status: .sending,
        isUnread: false,
        text: text,
        roundURL: sendReport.roundURL!
      ),
    ])
    XCTAssertNoDifference(messengerDidSendMessageWithParams, [
      .init(recipientId: recipientId, payload: try! MessagePayload(text: text).encode())
    ])
    XCTAssertNoDifference(dbDidFetchMessagesWithQuery, [
      .init(id: [messageId])
    ])

    dbDidBulkUpdateMessages = []
    didComplete = 0
    messengerDidSendMessageWithDeliveryCallback.first??(.init(
      report: sendReport,
      result: .delivered
    ))

    XCTAssertNoDifference(dbDidBulkUpdateMessages, [
      .init(query: .init(id: [messageId]), assignments: .init(status: .sent))
    ])
    XCTAssertNoDifference(didComplete, 1)

    dbDidBulkUpdateMessages = []
    didComplete = 0
    messengerDidSendMessageWithDeliveryCallback.first??(.init(
      report: sendReport,
      result: .notDelivered(timedOut: true)
    ))

    XCTAssertNoDifference(dbDidBulkUpdateMessages, [
      .init(query: .init(id: [messageId]), assignments: .init(status: .sendingTimedOut))
    ])
    XCTAssertNoDifference(didComplete, 1)

    dbDidBulkUpdateMessages = []
    didComplete = 0
    messengerDidSendMessageWithDeliveryCallback.first??(.init(
      report: sendReport,
      result: .notDelivered(timedOut: false)
    ))

    XCTAssertNoDifference(dbDidBulkUpdateMessages, [
      .init(query: .init(id: [messageId]), assignments: .init(status: .sendingFailed))
    ])
    XCTAssertNoDifference(didComplete, 1)

    dbDidBulkUpdateMessages = []
    didComplete = 0
    let deliveryFailure = NSError(domain: "test", code: 123)
    messengerDidSendMessageWithDeliveryCallback.first??(.init(
      report: sendReport,
      result: .failure(deliveryFailure)
    ))
    XCTAssertNoDifference(didComplete, 1)

    XCTAssertNoDifference(dbDidBulkUpdateMessages, [
      .init(query: .init(id: [messageId]), assignments: .init(status: .sendingFailed))
    ])
    XCTAssertNoDifference(didReceiveError.count, 1)
    XCTAssertNoDifference(didReceiveError.first as NSError?, deliveryFailure)
    XCTAssertNoDifference(didComplete, 1)
  }

  func testSendDatabaseFailure() {
    struct Failure: Error, Equatable {}
    let error = Failure()

    var didReceiveError: [Error] = []
    var didComplete = 0

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
    var db: DBManagerGetDB = .unimplemented
    db.run = { throw error }
    let send: SendMessage = .live(
      messenger: messenger,
      db: db,
      now: XCTUnimplemented("now", placeholder: Date())
    )

    send(
      text: "Hello",
      to: "recipient-id".data(using: .utf8)!,
      onError: { error in didReceiveError.append(error) },
      completion: { didComplete += 1 }
    )

    XCTAssertNoDifference(didReceiveError.count, 1)
    XCTAssertNoDifference(didReceiveError.first as? Failure, error)
    XCTAssertNoDifference(didComplete, 1)
  }

  func testBulkUpdateOnDeliveryFailure() {
    struct Failure: Error, Equatable {}
    let error = Failure()
    let sendReport = E2ESendReport(
      rounds: [],
      roundURL: "",
      messageId: Data(),
      timestamp: 0,
      keyResidue: Data()
    )

    var messengerDidSendMessageWithDeliveryCallback: [MessengerSendMessage.DeliveryCallback?] = []
    var didReceiveError: [Error] = []
    var didComplete = 0

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
    messenger.sendMessage.run = { _, _, deliveryCallback in
      messengerDidSendMessageWithDeliveryCallback.append(deliveryCallback)
      return sendReport
    }
    var db: DBManagerGetDB = .unimplemented
    db.run = {
      var db: Database = .failing
      db.saveMessage.run = { $0 }
      db.fetchMessages.run = { _ in [] }
      db.bulkUpdateMessages.run = { _, _ in throw error }
      return db
    }
    let send: SendMessage = .live(
      messenger: messenger,
      db: db,
      now: Date.init
    )

    send(
      text: "Hello",
      to: "recipient-id".data(using: .utf8)!,
      onError: { error in didReceiveError.append(error) },
      completion: { didComplete += 1 }
    )

    messengerDidSendMessageWithDeliveryCallback.first??(.init(
      report: sendReport,
      result: .delivered
    ))

    XCTAssertNoDifference(didReceiveError.count, 1)
    XCTAssertNoDifference(didReceiveError.first as? Failure, error)
    XCTAssertNoDifference(didComplete, 1)
  }
}

