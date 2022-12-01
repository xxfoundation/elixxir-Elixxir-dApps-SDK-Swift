import Combine
import ComposableArchitecture
import CustomDump
import XCTest
import XXClient
import XXMessengerClient
import XXModels
@testable import NewGroupFeature

final class NewGroupComponentTests: XCTestCase {
  enum Action: Equatable {
    case didFetchContacts(XXModels.Contact.Query)
    case didMakeGroup(membership: [Data], message: Data?, name: Data?)
    case didSaveGroup(XXModels.Group)
    case didSaveMessage(XXModels.Message)
    case didSaveGroupMember(XXModels.GroupMember)
  }

  var actions: [Action]!

  override func setUp() {
    actions = []
  }

  override func tearDown() {
    actions = nil
  }

  func testStart() {
    let contactsSubject = PassthroughSubject<[XXModels.Contact], Error>()

    let store = TestStore(
      initialState: NewGroupComponent.State(),
      reducer: NewGroupComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact = XXClient.Contact.unimplemented("my-contact-data".data(using: .utf8)!)
        contact.getIdFromContact.run = { _ in "my-contact-id".data(using: .utf8)! }
        return contact
      }
      return e2e
    }
    store.dependencies.app.dbManager.getDB.run = {
      var db: Database = .unimplemented
      db.fetchContactsPublisher.run = { query in
        self.actions.append(.didFetchContacts(query))
        return contactsSubject.eraseToAnyPublisher()
      }
      return db
    }

    store.send(.start)

    XCTAssertNoDifference(actions, [
      .didFetchContacts(.init())
    ])

    let contacts: [XXModels.Contact] = [
      .init(id: "contact-1-id".data(using: .utf8)!),
      .init(id: "contact-2-id".data(using: .utf8)!),
      .init(id: "contact-3-id".data(using: .utf8)!),
    ]
    contactsSubject.send(contacts)

    store.receive(.didFetchContacts(contacts)) {
      $0.contacts = IdentifiedArray(uniqueElements: contacts)
    }

    contactsSubject.send(completion: .finished)
  }

  func testSelectMembers() {
    let contacts: [XXModels.Contact] = [
      .init(id: "contact-1-id".data(using: .utf8)!),
      .init(id: "contact-2-id".data(using: .utf8)!),
      .init(id: "contact-3-id".data(using: .utf8)!),
    ]

    let store = TestStore(
      initialState: NewGroupComponent.State(
        contacts: IdentifiedArray(uniqueElements: contacts)
      ),
      reducer: NewGroupComponent()
    )

    store.send(.didSelectContact(contacts[0])) {
      $0.members = IdentifiedArray(uniqueElements: [contacts[0]])
    }

    store.send(.didSelectContact(contacts[1])) {
      $0.members = IdentifiedArray(uniqueElements: [contacts[0], contacts[1]])
    }

    store.send(.didSelectContact(contacts[0])) {
      $0.members = IdentifiedArray(uniqueElements: [contacts[1]])
    }
  }

  func testEnterGroupName() {
    let store = TestStore(
      initialState: NewGroupComponent.State(),
      reducer: NewGroupComponent()
    )

    store.send(.binding(.set(\.$focusedField, .name))) {
      $0.focusedField = .name
    }

    store.send(.binding(.set(\.$name, "My New Group"))) {
      $0.name = "My New Group"
    }

    store.send(.binding(.set(\.$focusedField, nil))) {
      $0.focusedField = nil
    }
  }

  func testEnterInitialMessage() {
    let store = TestStore(
      initialState: NewGroupComponent.State(),
      reducer: NewGroupComponent()
    )

    store.send(.binding(.set(\.$focusedField, .message))) {
      $0.focusedField = .message
    }

    store.send(.binding(.set(\.$message, "Welcome message"))) {
      $0.message = "Welcome message"
    }

    store.send(.binding(.set(\.$focusedField, nil))) {
      $0.focusedField = nil
    }
  }

  func testCreateGroup() {
    let members: [XXModels.Contact] = [
      .init(id: "member-contact-1".data(using: .utf8)!),
      .init(id: "member-contact-2".data(using: .utf8)!),
      .init(id: "member-contact-3".data(using: .utf8)!),
    ]
    let name = "New group"
    let message = "Welcome message"
    let groupReport = GroupReport(
      id: "new-group-id".data(using: .utf8)!,
      rounds: [],
      roundURL: "",
      status: 0
    )
    let myContactId = "my-contact-id".data(using: .utf8)!
    let currentDate = Date(timeIntervalSince1970: 123)

    let store = TestStore(
      initialState: NewGroupComponent.State(
        members: IdentifiedArray(uniqueElements: members),
        name: name,
        message: message
      ),
      reducer: NewGroupComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.groupChat.get = {
      var groupChat: GroupChat = .unimplemented
      groupChat.makeGroup.run = { membership, message, name in
        self.actions.append(.didMakeGroup(
          membership: membership,
          message: message,
          name: name
        ))
        return groupReport
      }
      return groupChat
    }
    store.dependencies.app.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact = XXClient.Contact.unimplemented("my-contact-data".data(using: .utf8)!)
        contact.getIdFromContact.run = { _ in myContactId }
        return contact
      }
      return e2e
    }
    store.dependencies.date = .constant(currentDate)
    store.dependencies.app.dbManager.getDB.run = {
      var db: Database = .unimplemented
      db.saveGroup.run = { group in
        self.actions.append(.didSaveGroup(group))
        return group
      }
      db.saveMessage.run = { message in
        self.actions.append(.didSaveMessage(message))
        return message
      }
      db.saveGroupMember.run = { groupMember in
        self.actions.append(.didSaveGroupMember(groupMember))
        return groupMember
      }
      return db
    }

    store.send(.createButtonTapped) {
      $0.isCreating = true
    }

    XCTAssertNoDifference(actions, [
      .didMakeGroup(
        membership: members.map(\.id),
        message: message.data(using: .utf8)!,
        name: name.data(using: .utf8)!
      ),
      .didSaveGroup(.init(
        id: groupReport.id,
        name: name,
        leaderId: myContactId,
        createdAt: currentDate,
        authStatus: .participating,
        serialized: try! groupReport.encode()
      )),
      .didSaveMessage(.init(
        senderId: myContactId,
        recipientId: nil,
        groupId: groupReport.id,
        date: currentDate,
        status: .sent,
        isUnread: false,
        text: message
      )),
      .didSaveGroupMember(.init(
        groupId: groupReport.id,
        contactId: members[0].id
      )),
      .didSaveGroupMember(.init(
        groupId: groupReport.id,
        contactId: members[1].id
      )),
      .didSaveGroupMember(.init(
        groupId: groupReport.id,
        contactId: members[2].id
      )),
    ])

    store.receive(.didFinish) {
      $0.isCreating = false
    }
  }

  func testCreateGroupFailure() {
    struct Failure: Error, Equatable {}
    let failure = Failure()

    let store = TestStore(
      initialState: NewGroupComponent.State(),
      reducer: NewGroupComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.groupChat.get = {
      var groupChat: GroupChat = .unimplemented
      groupChat.makeGroup.run = { _, _, _ in throw failure }
      return groupChat
    }

    store.send(.createButtonTapped) {
      $0.isCreating = true
    }

    store.receive(.didFail(failure.localizedDescription)) {
      $0.isCreating = false
      $0.failure = failure.localizedDescription
    }
  }

  func testFinish() {
    let store = TestStore(
      initialState: NewGroupComponent.State(),
      reducer: NewGroupComponent()
    )

    store.send(.didFinish)
  }
}
