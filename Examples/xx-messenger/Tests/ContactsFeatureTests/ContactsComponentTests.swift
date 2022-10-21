import Combine
import ComposableArchitecture
import ContactFeature
import CustomDump
import MyContactFeature
import XCTest
import XXClient
import XXMessengerClient
import XXModels
@testable import ContactsFeature

final class ContactsComponentTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: ContactsComponent.State(),
      reducer: ContactsComponent()
    )

    let myId = "2".data(using: .utf8)!
    var didFetchContacts: [XXModels.Contact.Query] = []
    let contactsPublisher = PassthroughSubject<[XXModels.Contact], Error>()

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented(Data())
        contact.getIdFromContact.run = { _ in myId }
        return contact
      }
      return e2e
    }
    store.dependencies.app.dbManager.getDB.run = {
      var db: Database = .unimplemented
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
      initialState: ContactsComponent.State(),
      reducer: ContactsComponent()
    )

    let contact = XXModels.Contact(id: "id".data(using: .utf8)!)

    store.send(.contactSelected(contact)) {
      $0.contact = ContactComponent.State(id: contact.id, dbContact: contact)
    }
  }

  func testDismissContact() {
    let store = TestStore(
      initialState: ContactsComponent.State(
        contact: ContactComponent.State(
          id: "id".data(using: .utf8)!,
          dbContact: Contact(id: "id".data(using: .utf8)!)
        )
      ),
      reducer: ContactsComponent()
    )

    store.send(.contactDismissed) {
      $0.contact = nil
    }
  }

  func testSelectMyContact() {
    let store = TestStore(
      initialState: ContactsComponent.State(),
      reducer: ContactsComponent()
    )

    store.send(.myContactSelected) {
      $0.myContact = MyContactComponent.State()
    }
  }

  func testDismissMyContact() {
    let store = TestStore(
      initialState: ContactsComponent.State(
        myContact: MyContactComponent.State()
      ),
      reducer: ContactsComponent()
    )

    store.send(.myContactDismissed) {
      $0.myContact = nil
    }
  }
}
