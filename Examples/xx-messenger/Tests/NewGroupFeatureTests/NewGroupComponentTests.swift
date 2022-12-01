import Combine
import ComposableArchitecture
import CustomDump
import XCTest
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

  func testFinish() {
    let store = TestStore(
      initialState: NewGroupComponent.State(),
      reducer: NewGroupComponent()
    )

    store.send(.didFinish)
  }
}
