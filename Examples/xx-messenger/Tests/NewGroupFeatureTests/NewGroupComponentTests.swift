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

  func testFinish() {
    let store = TestStore(
      initialState: NewGroupComponent.State(),
      reducer: NewGroupComponent()
    )

    store.send(.didFinish)
  }
}
