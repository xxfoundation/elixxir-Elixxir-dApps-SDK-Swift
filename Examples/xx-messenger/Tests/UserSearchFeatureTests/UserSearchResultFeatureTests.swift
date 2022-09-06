import Combine
import ComposableArchitecture
import XCTest
import XCTestDynamicOverlay
import XXClient
import XXModels
@testable import UserSearchFeature

final class UserSearchResultFeatureTests: XCTestCase {
  func testStart() {
    var contact = Contact.unimplemented("contact-data".data(using: .utf8)!)
    contact.getFactsFromContact.run = { _ in
      [
        Fact(fact: "contact-username", type: 0),
        Fact(fact: "contact-email", type: 1),
        Fact(fact: "contact-phone", type: 2),
      ]
    }

    let store = TestStore(
      initialState: UserSearchResultState(
        id: "contact-id".data(using: .utf8)!,
        xxContact: contact
      ),
      reducer: userSearchResultReducer,
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

    store.send(.start) {
      $0.username = "contact-username"
      $0.email = "contact-email"
      $0.phone = "contact-phone"
    }

    XCTAssertNoDifference(dbDidFetchContacts, [
      .init(id: ["contact-id".data(using: .utf8)!])
    ])

    let dbContact = XXModels.Contact(id: "contact-id".data(using: .utf8)!)
    dbContactsPublisher.send([dbContact])

    store.receive(.didUpdateContact(dbContact)) {
      $0.dbContact = dbContact
    }

    dbContactsPublisher.send(completion: .finished)
  }

  func testSendRequest() {
    let store = TestStore(
      initialState: UserSearchResultState(
        id: "contact-id".data(using: .utf8)!,
        xxContact: .unimplemented("contact-data".data(using: .utf8)!)
      ),
      reducer: userSearchResultReducer,
      environment: .unimplemented
    )

    store.send(.sendRequestButtonTapped)
  }
}
