import Combine
import ComposableArchitecture
import XCTest
import XXClient
import XXModels
@testable import SendRequestFeature

final class SendRequestFeatureTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: SendRequestState(
        contact: .unimplemented("contact-data".data(using: .utf8)!)
      ),
      reducer: sendRequestReducer,
      environment: .unimplemented
    )

    var dbDidFetchContacts: [XXModels.Contact.Query] = []
    let dbContactsPublisher = PassthroughSubject<[XXModels.Contact], Error>()

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.messenger.e2e.get = {
      var e2e: E2E = .unimplemented
      e2e.getContact.run = {
        var contact: XXClient.Contact = .unimplemented("my-contact-data".data(using: .utf8)!)
        contact.getIdFromContact.run = { _ in "my-contact-id".data(using: .utf8)! }
        return contact
      }
      return e2e
    }
    store.environment.db.run = {
      var db: Database = .failing
      db.fetchContactsPublisher.run = { query in
        dbDidFetchContacts.append(query)
        return dbContactsPublisher.eraseToAnyPublisher()
      }
      return db
    }

    store.send(.start)

    XCTAssertNoDifference(dbDidFetchContacts, [.init(id: ["my-contact-id".data(using: .utf8)!])])

    dbContactsPublisher.send([])

    store.receive(.myContactFetched(nil))

    var myDbContact = XXModels.Contact(id: "my-contact-id".data(using: .utf8)!)
    myDbContact.marshaled = "my-contact-data".data(using: .utf8)!
    dbContactsPublisher.send([myDbContact])

    store.receive(.myContactFetched(.live("my-contact-data".data(using: .utf8)!))) {
      $0.myContact = .live("my-contact-data".data(using: .utf8)!)
    }

    dbContactsPublisher.send(completion: .finished)
  }

  func testSendRequest() {
    var myContact: XXClient.Contact = .unimplemented("my-contact-data".data(using: .utf8)!)
    myContact.getFactsFromContact.run = { _ in
      [
        Fact(fact: "my-username", type: 0),
        Fact(fact: "my-email", type: 1),
        Fact(fact: "my-phone", type: 2),
      ]
    }

    let store = TestStore(
      initialState: SendRequestState(
        contact: .unimplemented("contact-data".data(using: .utf8)!),
        myContact: myContact
      ),
      reducer: sendRequestReducer,
      environment: .unimplemented
    )

    store.send(.set(\.$sendPhone, false)) {
      $0.sendPhone = false
    }

    store.send(.sendTapped)
  }
}
