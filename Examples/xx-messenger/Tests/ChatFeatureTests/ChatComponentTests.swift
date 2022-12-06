import AppCore
import Combine
import ComposableArchitecture
import CustomDump
import XCTest
import XXClient
import XXMessengerClient
import XXModels
@testable import ChatFeature

final class ChatComponentTests: XCTestCase {
  func testStartDirectChat() {
    let contactId = "contact-id".data(using: .utf8)!
    let myContactId = "my-contact-id".data(using: .utf8)!

    let store = TestStore(
      initialState: ChatComponent.State(id: .contact(contactId)),
      reducer: ChatComponent()
    )

    var didFetchMessagesWithQuery: [XXModels.Message.Query] = []
    let messagesPublisher = PassthroughSubject<[XXModels.Message], Error>()
    var didFetchFileTransfersWithQuery: [XXModels.FileTransfer.Query] = []
    let fileTransfersPublisher = PassthroughSubject<[XXModels.FileTransfer], Error>()
    var didFetchContactsWithQuery: [XXModels.Contact.Query] = []
    let contactsPublisher = PassthroughSubject<[XXModels.Contact], Error>()

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented(Data())
        contact.getIdFromContact.run = { _ in myContactId }
        return contact
      }
      return e2e
    }
    store.dependencies.app.dbManager.getDB.run = {
      var db: Database = .unimplemented
      db.fetchMessagesPublisher.run = { query in
        didFetchMessagesWithQuery.append(query)
        return messagesPublisher.eraseToAnyPublisher()
      }
      db.fetchContactsPublisher.run = { query in
        didFetchContactsWithQuery.append(query)
        return contactsPublisher.eraseToAnyPublisher()
      }
      db.fetchFileTransfersPublisher.run = { query in
        didFetchFileTransfersWithQuery.append(query)
        return fileTransfersPublisher.eraseToAnyPublisher()
      }
      return db
    }

    store.send(.start) {
      $0.myContactId = myContactId
    }

    XCTAssertNoDifference(didFetchMessagesWithQuery, [
      .init(chat: .direct(myContactId, contactId))
    ])
    XCTAssertNoDifference(didFetchFileTransfersWithQuery, [
      .init(contactId: contactId, isIncoming: true),
      .init(contactId: myContactId, isIncoming: false),
    ])
    XCTAssertNoDifference(didFetchContactsWithQuery, [
      .init(),
    ])

    let receivedFileTransfer = FileTransfer(
      id: "file-transfer-1-id".data(using: .utf8)!,
      contactId: contactId,
      name: "file-transfer-1-name",
      type: "file-transfer-1-type",
      isIncoming: true
    )
    let sentFileTransfer = FileTransfer(
      id: "file-transfer-2-id".data(using: .utf8)!,
      contactId: myContactId,
      name: "file-transfer-2-name",
      type: "file-transfer-2-type",
      isIncoming: false
    )
    messagesPublisher.send([
      .init(
        id: nil,
        senderId: contactId,
        recipientId: myContactId,
        groupId: nil,
        date: Date(timeIntervalSince1970: 0),
        status: .received,
        isUnread: false,
        text: "Message 0"
      ),
      .init(
        id: 1,
        senderId: contactId,
        recipientId: myContactId,
        groupId: nil,
        date: Date(timeIntervalSince1970: 1),
        status: .received,
        isUnread: false,
        text: "Message 1",
        fileTransferId: receivedFileTransfer.id
      ),
      .init(
        id: 2,
        senderId: myContactId,
        recipientId: contactId,
        groupId: nil,
        date: Date(timeIntervalSince1970: 2),
        status: .sent,
        isUnread: false,
        text: "Message 2",
        fileTransferId: sentFileTransfer.id
      ),
    ])
    fileTransfersPublisher.send([
      receivedFileTransfer,
      sentFileTransfer,
    ])
    contactsPublisher.send([
      .init(id: myContactId, username: "My username"),
      .init(id: contactId, username: "Contact username"),
    ])

    let expectedMessages = IdentifiedArrayOf<ChatComponent.State.Message>(uniqueElements: [
      .init(
        id: 1,
        date: Date(timeIntervalSince1970: 1),
        senderId: contactId,
        senderName: "Contact username",
        text: "Message 1",
        status: .received,
        fileTransfer: receivedFileTransfer
      ),
      .init(
        id: 2,
        date: Date(timeIntervalSince1970: 2),
        senderId: myContactId,
        senderName: "My username",
        text: "Message 2",
        status: .sent,
        fileTransfer: sentFileTransfer
      ),
    ])

    store.receive(.didFetchMessages(expectedMessages)) {
      $0.messages = expectedMessages
    }

    messagesPublisher.send(completion: .finished)
    fileTransfersPublisher.send(completion: .finished)
    contactsPublisher.send(completion: .finished)
  }

  func testStartGroupChat() {
    let groupId = "group-id".data(using: .utf8)!
    let myContactId = "my-contact-id".data(using: .utf8)!
    let firstMemberId = "member-1-id".data(using: .utf8)!
    let secondMemberId = "member-2-id".data(using: .utf8)!

    let store = TestStore(
      initialState: ChatComponent.State(id: .group(groupId)),
      reducer: ChatComponent()
    )

    var didFetchMessagesWithQuery: [XXModels.Message.Query] = []
    let messagesPublisher = PassthroughSubject<[XXModels.Message], Error>()
    var didFetchContactsWithQuery: [XXModels.Contact.Query] = []
    let contactsPublisher = PassthroughSubject<[XXModels.Contact], Error>()

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented(Data())
        contact.getIdFromContact.run = { _ in myContactId }
        return contact
      }
      return e2e
    }
    store.dependencies.app.dbManager.getDB.run = {
      var db: Database = .unimplemented
      db.fetchMessagesPublisher.run = { query in
        didFetchMessagesWithQuery.append(query)
        return messagesPublisher.eraseToAnyPublisher()
      }
      db.fetchContactsPublisher.run = { query in
        didFetchContactsWithQuery.append(query)
        return contactsPublisher.eraseToAnyPublisher()
      }
      return db
    }

    store.send(.start) {
      $0.myContactId = myContactId
    }

    XCTAssertNoDifference(didFetchMessagesWithQuery, [
      .init(chat: .group(groupId))
    ])
    XCTAssertNoDifference(didFetchContactsWithQuery, [
      .init(),
    ])

    messagesPublisher.send([
      .init(
        id: 0,
        senderId: myContactId,
        recipientId: nil,
        groupId: groupId,
        date: Date(timeIntervalSince1970: 0),
        status: .sent,
        isUnread: false,
        text: "Message 0"
      ),
      .init(
        id: 1,
        senderId: firstMemberId,
        recipientId: nil,
        groupId: groupId,
        date: Date(timeIntervalSince1970: 1),
        status: .received,
        isUnread: false,
        text: "Message 1"
      ),
      .init(
        id: 2,
        senderId: secondMemberId,
        recipientId: nil,
        groupId: groupId,
        date: Date(timeIntervalSince1970: 2),
        status: .received,
        isUnread: false,
        text: "Message 2"
      ),
    ])
    contactsPublisher.send([
      .init(id: myContactId, username: "My username"),
      .init(id: firstMemberId, username: "First username"),
      .init(id: secondMemberId, username: "Second username"),
    ])

    let expectedMessages = IdentifiedArrayOf<ChatComponent.State.Message>(uniqueElements: [
      .init(
        id: 0,
        date: Date(timeIntervalSince1970: 0),
        senderId: myContactId,
        senderName: "My username",
        text: "Message 0",
        status: .sent
      ),
      .init(
        id: 1,
        date: Date(timeIntervalSince1970: 1),
        senderId: firstMemberId,
        senderName: "First username",
        text: "Message 1",
        status: .received
      ),
      .init(
        id: 2,
        date: Date(timeIntervalSince1970: 2),
        senderId: secondMemberId,
        senderName: "Second username",
        text: "Message 2",
        status: .received
      ),
    ])

    store.receive(.didFetchMessages(expectedMessages)) {
      $0.messages = expectedMessages
    }

    messagesPublisher.send(completion: .finished)
    contactsPublisher.send(completion: .finished)
  }

  func testStartFailure() {
    let store = TestStore(
      initialState: ChatComponent.State(id: .contact("contact-id".data(using: .utf8)!)),
      reducer: ChatComponent()
    )

    struct Failure: Error {}
    let error = Failure()

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented(Data())
        contact.getIdFromContact.run = { _ in throw error }
        return contact
      }
      return e2e
    }

    store.send(.start) {
      $0.failure = error.localizedDescription
    }
  }

  func testSendDirectMessage() {
    struct SendMessageParams: Equatable {
      var text: String
      var recipientId: Data
    }
    var didSendMessageWithParams: [SendMessageParams] = []
    var sendMessageCompletion: SendMessage.Completion?

    let store = TestStore(
      initialState: ChatComponent.State(id: .contact("contact-id".data(using: .utf8)!)),
      reducer: ChatComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.sendMessage.run = { text, recipientId, _, completion in
      didSendMessageWithParams.append(.init(text: text, recipientId: recipientId))
      sendMessageCompletion = completion
    }

    store.send(.set(\.$text, "Hello")) {
      $0.text = "Hello"
    }

    store.send(.sendTapped) {
      $0.text = ""
    }

    XCTAssertNoDifference(didSendMessageWithParams, [
      .init(text: "Hello", recipientId: "contact-id".data(using: .utf8)!)
    ])

    sendMessageCompletion?()
  }

  func testSendDirectMessageFailure() {
    var sendMessageOnError: SendMessage.OnError?
    var sendMessageCompletion: SendMessage.Completion?

    let store = TestStore(
      initialState: ChatComponent.State(
        id: .contact("contact-id".data(using: .utf8)!),
        text: "Hello"
      ),
      reducer: ChatComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.sendMessage.run = { _, _, onError, completion in
      sendMessageOnError = onError
      sendMessageCompletion = completion
    }

    store.send(.sendTapped) {
      $0.text = ""
    }

    let error = NSError(domain: "test", code: 123)
    sendMessageOnError?(error)

    store.receive(.sendFailed(error.localizedDescription)) {
      $0.sendFailure = error.localizedDescription
    }

    sendMessageCompletion?()

    store.send(.dismissSendFailureTapped) {
      $0.sendFailure = nil
    }
  }

  func testSendGroupMessage() {
    let groupId = "group-id".data(using: .utf8)!
    let text = "Hello"
    struct SendGroupMessageParams: Equatable {
      var text: String
      var groupId: Data
    }
    var didSendGroupMessageWithParams: [SendGroupMessageParams] = []
    var sendGroupMessageCompletion: SendGroupMessage.Completion?

    let store = TestStore(
      initialState: ChatComponent.State(id: .group(groupId)),
      reducer: ChatComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.sendGroupMessage.run = { text, groupId, _, completion in
      didSendGroupMessageWithParams.append(.init(text: text, groupId: groupId))
      sendGroupMessageCompletion = completion
    }

    store.send(.set(\.$text, text)) {
      $0.text = text
    }

    store.send(.sendTapped) {
      $0.text = ""
    }

    XCTAssertNoDifference(didSendGroupMessageWithParams, [
      .init(text: text, groupId: groupId)
    ])

    sendGroupMessageCompletion?()
  }

  func testSendGroupMessageFailure() {
    var sendGroupMessageOnError: SendGroupMessage.OnError?
    var sendGroupMessageCompletion: SendGroupMessage.Completion?

    let store = TestStore(
      initialState: ChatComponent.State(
        id: .group("group-id".data(using: .utf8)!),
        text: "Hello"
      ),
      reducer: ChatComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.sendGroupMessage.run = { _, _, onError, completion in
      sendGroupMessageOnError = onError
      sendGroupMessageCompletion = completion
    }

    store.send(.sendTapped) {
      $0.text = ""
    }

    let error = NSError(domain: "test", code: 123)
    sendGroupMessageOnError?(error)

    store.receive(.sendFailed(error.localizedDescription)) {
      $0.sendFailure = error.localizedDescription
    }

    sendGroupMessageCompletion?()

    store.send(.dismissSendFailureTapped) {
      $0.sendFailure = nil
    }
  }

  func testSendImage() {
    struct SendImageParams: Equatable {
      var image: Data
      var recipientId: Data
    }
    var didSendImageWithParams: [SendImageParams] = []
    var sendImageCompletion: SendImage.Completion?

    let store = TestStore(
      initialState: ChatComponent.State(id: .contact("contact-id".data(using: .utf8)!)),
      reducer: ChatComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.sendImage.run = { image, recipientId, _, completion in
      didSendImageWithParams.append(.init(image: image, recipientId: recipientId))
      sendImageCompletion = completion
    }

    let image = "image-data".data(using: .utf8)!
    store.send(.imagePicked(image))

    XCTAssertNoDifference(didSendImageWithParams, [
      .init(image: image, recipientId: "contact-id".data(using: .utf8)!)
    ])

    sendImageCompletion?()
  }

  func testSendImageFailure() {
    var sendImageOnError: SendImage.OnError?
    var sendImageCompletion: SendImage.Completion?

    let store = TestStore(
      initialState: ChatComponent.State(
        id: .contact("contact-id".data(using: .utf8)!)
      ),
      reducer: ChatComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.sendImage.run = { _, _, onError, completion in
      sendImageOnError = onError
      sendImageCompletion = completion
    }

    store.send(.imagePicked(Data()))

    let error = NSError(domain: "test", code: 123)
    sendImageOnError?(error)

    store.receive(.sendFailed(error.localizedDescription)) {
      $0.sendFailure = error.localizedDescription
    }

    sendImageCompletion?()

    store.send(.dismissSendFailureTapped) {
      $0.sendFailure = nil
    }
  }
}
