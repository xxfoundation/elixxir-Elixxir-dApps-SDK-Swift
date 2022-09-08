import Combine
import ComposableArchitecture
import CustomDump
import XCTest
import XXModels
@testable import ContactsFeature

final class ContactsFeatureTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: ContactsState(),
      reducer: contactsReducer,
      environment: .unimplemented
    )

    var didFetchContacts: [XXModels.Contact.Query] = []
    let contactsPublisher = PassthroughSubject<[XXModels.Contact], Error>()

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.db.run = {
      var db: Database = .failing
      db.fetchContactsPublisher.run = { query in
        didFetchContacts.append(query)
        return contactsPublisher.eraseToAnyPublisher()
      }
      return db
    }

    store.send(.start)

    XCTAssertNoDifference(didFetchContacts, [XXModels.Contact.Query()])

    let contacts: [XXModels.Contact] = [
      .init(id: "1".data(using: .utf8)!),
      .init(id: "2".data(using: .utf8)!),
      .init(id: "3".data(using: .utf8)!),
    ]
    contactsPublisher.send(contacts)

    store.receive(.didFetchContacts(contacts)) {
      $0.contacts = IdentifiedArray(uniqueElements: contacts)
    }

    contactsPublisher.send(completion: .finished)
  }
}
