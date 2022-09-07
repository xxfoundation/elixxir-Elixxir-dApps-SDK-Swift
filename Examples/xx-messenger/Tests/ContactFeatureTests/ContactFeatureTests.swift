import Combine
import ComposableArchitecture
import CustomDump
import XCTest
import XXClient
import XXModels
@testable import ContactFeature

final class ContactFeatureTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: ContactState(
        id: "contact-id".data(using: .utf8)!
      ),
      reducer: contactReducer,
      environment: .unimplemented
    )

    var dbDidFetchContacts: [XXModels.Contact.Query] = []
    let dbContactsPublisher = PassthroughSubject<[XXModels.Contact], Error>()

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.db.run = {
      var db: Database = .failing
      db.fetchContactsPublisher.run = { query in
        dbDidFetchContacts.append(query)
        return dbContactsPublisher.eraseToAnyPublisher()
      }
      return db
    }

    store.send(.start)

    XCTAssertNoDifference(dbDidFetchContacts, [
      .init(id: ["contact-id".data(using: .utf8)!])
    ])

    let dbContact = XXModels.Contact(id: "contact-id".data(using: .utf8)!)
    dbContactsPublisher.send([dbContact])

    store.receive(.dbContactFetched(dbContact)) {
      $0.dbContact = dbContact
    }

    dbContactsPublisher.send(completion: .finished)
  }

  func testSaveFacts() {
    let dbContact: XXModels.Contact = .init(
      id: "contact-id".data(using: .utf8)!
    )

    var xxContact: XXClient.Contact = .unimplemented("contact-data".data(using: .utf8)!)
    xxContact.getFactsFromContact.run = { _ in
      [
        Fact(fact: "contact-username", type: 0),
        Fact(fact: "contact-email", type: 1),
        Fact(fact: "contact-phone", type: 2),
      ]
    }

    let store = TestStore(
      initialState: ContactState(
        id: "contact-id".data(using: .utf8)!,
        dbContact: dbContact,
        xxContact: xxContact
      ),
      reducer: contactReducer,
      environment: .unimplemented
    )

    var dbDidSaveContact: [XXModels.Contact] = []

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.db.run = {
      var db: Database = .failing
      db.saveContact.run = { contact in
        dbDidSaveContact.append(contact)
        return contact
      }
      return db
    }

    store.send(.saveFactsTapped)

    var expectedSavedContact = dbContact
    expectedSavedContact.marshaled = xxContact.data
    expectedSavedContact.username = "contact-username"
    expectedSavedContact.email = "contact-email"
    expectedSavedContact.phone = "contact-phone"

    XCTAssertNoDifference(dbDidSaveContact, [expectedSavedContact])
  }

  func testSendRequest() {
    let store = TestStore(
      initialState: ContactState(
        id: "contact-id".data(using: .utf8)!
      ),
      reducer: contactReducer,
      environment: .unimplemented
    )

    store.send(.sendRequestTapped) {
      $0.sendRequest = ContactSendRequestState()
    }

    store.send(.sendRequestDismissed) {
      $0.sendRequest = nil
    }
  }
}
