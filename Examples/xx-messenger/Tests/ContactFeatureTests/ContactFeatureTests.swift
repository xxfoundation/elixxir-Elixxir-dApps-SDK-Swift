import Combine
import ComposableArchitecture
import CustomDump
import SendRequestFeature
import VerifyContactFeature
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

  func testImportFacts() {
    let dbContact: XXModels.Contact = .init(
      id: "contact-id".data(using: .utf8)!
    )

    var xxContact: XXClient.Contact = .unimplemented("contact-data".data(using: .utf8)!)
    xxContact.getFactsFromContact.run = { _ in
      [
        Fact(type: .username, value: "contact-username"),
        Fact(type: .email, value: "contact-email"),
        Fact(type: .phone, value: "contact-phone"),
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

    store.send(.importFactsTapped)

    var expectedSavedContact = dbContact
    expectedSavedContact.marshaled = xxContact.data
    expectedSavedContact.username = "contact-username"
    expectedSavedContact.email = "contact-email"
    expectedSavedContact.phone = "contact-phone"

    XCTAssertNoDifference(dbDidSaveContact, [expectedSavedContact])
  }

  func testSendRequestWithDBContact() {
    var dbContact = XXModels.Contact(id: "contact-id".data(using: .utf8)!)
    dbContact.marshaled = "contact-data".data(using: .utf8)!

    let store = TestStore(
      initialState: ContactState(
        id: dbContact.id,
        dbContact: dbContact
      ),
      reducer: contactReducer,
      environment: .unimplemented
    )

    store.send(.sendRequestTapped) {
      $0.sendRequest = SendRequestState(contact: .live(dbContact.marshaled!))
    }
  }

  func testSendRequestWithXXContact() {
    let xxContact = XXClient.Contact.unimplemented("contact-id".data(using: .utf8)!)

    let store = TestStore(
      initialState: ContactState(
        id: "contact-id".data(using: .utf8)!,
        xxContact: xxContact
      ),
      reducer: contactReducer,
      environment: .unimplemented
    )

    store.send(.sendRequestTapped) {
      $0.sendRequest = SendRequestState(contact: xxContact)
    }
  }

  func testSendRequestDismissed() {
    let store = TestStore(
      initialState: ContactState(
        id: "contact-id".data(using: .utf8)!,
        sendRequest: SendRequestState(
          contact: .unimplemented("contact-id".data(using: .utf8)!)
        )
      ),
      reducer: contactReducer,
      environment: .unimplemented
    )

    store.send(.sendRequestDismissed) {
      $0.sendRequest = nil
    }
  }

  func testSendRequestSucceeded() {
    let store = TestStore(
      initialState: ContactState(
        id: "contact-id".data(using: .utf8)!,
        sendRequest: SendRequestState(
          contact: .unimplemented("contact-id".data(using: .utf8)!)
        )
      ),
      reducer: contactReducer,
      environment: .unimplemented
    )

    store.send(.sendRequest(.sendSucceeded)) {
      $0.sendRequest = nil
    }
  }

  func testVerifyContactTapped() {
    let contactData = "contact-data".data(using: .utf8)!
    let store = TestStore(
      initialState: ContactState(
        id: Data(),
        dbContact: XXModels.Contact(
          id: Data(),
          marshaled: contactData
        )
      ),
      reducer: contactReducer,
      environment: .unimplemented
    )

    store.send(.verifyContactTapped) {
      $0.verifyContact = VerifyContactState(
        contact: .unimplemented(contactData)
      )
    }
  }

  func testVerifyContactDismissed() {
    let store = TestStore(
      initialState: ContactState(
        id: "contact-id".data(using: .utf8)!,
        verifyContact: VerifyContactState(
          contact: .unimplemented("contact-data".data(using: .utf8)!)
        )
      ),
      reducer: contactReducer,
      environment: .unimplemented
    )

    store.send(.verifyContactDismissed) {
      $0.verifyContact = nil
    }
  }
}
