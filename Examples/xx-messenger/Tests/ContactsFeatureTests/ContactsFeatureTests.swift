import Combine
import ComposableArchitecture
import ContactFeature
import CustomDump
import XCTest
import XXClient
import XXMessengerClient
import XXModels
@testable import ContactsFeature

final class ContactsFeatureTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: ContactsState(),
      reducer: contactsReducer,
      environment: .unimplemented
    )

    let myId = "2".data(using: .utf8)!
    var didFetchContacts: [XXModels.Contact.Query] = []
    let contactsPublisher = PassthroughSubject<[XXModels.Contact], Error>()

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented(Data())
        contact.getIdFromContact.run = { _ in myId }
        return contact
      }
      return e2e
    }
    store.environment.db.run = {
      var db: Database = .failing
      db.fetchContactsPublisher.run = { query in
        didFetchContacts.append(query)
        return contactsPublisher.eraseToAnyPublisher()
      }
      return db
    }

    store.send(.start) {
      $0.myId = myId
    }

    XCTAssertNoDifference(didFetchContacts, [XXModels.Contact.Query()])

    let contacts: [XXModels.Contact] = [
      .init(id: "1".data(using: .utf8)!),
      .init(id: "2".data(using: .utf8)!),
      .init(id: "3".data(using: .utf8)!),
    ]
    contactsPublisher.send(contacts)

    store.receive(.didFetchContacts(contacts)) {
      $0.contacts = IdentifiedArray(uniqueElements: [
        contacts[1],
        contacts[0],
        contacts[2],
      ])
    }

    contactsPublisher.send(completion: .finished)
  }

  func testSelectContact() {
    let store = TestStore(
      initialState: ContactsState(),
      reducer: contactsReducer,
      environment: .unimplemented
    )

    let contact = XXModels.Contact(id: "id".data(using: .utf8)!)

    store.send(.contactSelected(contact)) {
      $0.contact = ContactState(id: contact.id, dbContact: contact)
    }
  }

  func testDismissContact() {
    let store = TestStore(
      initialState: ContactsState(
        contact: ContactState(
          id: "id".data(using: .utf8)!,
          dbContact: Contact(id: "id".data(using: .utf8)!)
        )
      ),
      reducer: contactsReducer,
      environment: .unimplemented
    )

    store.send(.contactDismissed) {
      $0.contact = nil
    }
  }
}
