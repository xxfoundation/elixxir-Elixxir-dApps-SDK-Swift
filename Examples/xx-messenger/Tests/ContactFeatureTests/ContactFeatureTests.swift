import Combine
import ComposableArchitecture
import CustomDump
import XCTest
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
    let store = TestStore(
      initialState: ContactState(
        id: "contact-id".data(using: .utf8)!
      ),
      reducer: contactReducer,
      environment: .unimplemented
    )

    store.send(.saveFactsTapped)
  }

  func testSendRequest() {
    let store = TestStore(
      initialState: ContactState(
        id: "contact-id".data(using: .utf8)!
      ),
      reducer: contactReducer,
      environment: .unimplemented
    )

    store.send(.sendRequestTapped)
  }
}
