import ComposableArchitecture
import XCTest
import XXClient
import XXMessengerClient
@testable import UserSearchFeature

final class UserSearchFeatureTests: XCTestCase {
  func testSearch() {
    let store = TestStore(
      initialState: UserSearchState(),
      reducer: userSearchReducer,
      environment: .unimplemented
    )

    var didSearchWithQuery: [MessengerSearchUsers.Query] = []

    struct GetIdFromContactError: Error {}
    struct GetFactsFromContactError: Error {}

    var contact1 = Contact.unimplemented("contact-1".data(using: .utf8)!)
    contact1.getIdFromContact.run = { _ in "contact-1-id".data(using: .utf8)! }
    var contact2 = Contact.unimplemented("contact-1".data(using: .utf8)!)
    contact2.getIdFromContact.run = { _ in "contact-2-id".data(using: .utf8)! }
    var contact3 = Contact.unimplemented("contact-3".data(using: .utf8)!)
    contact3.getIdFromContact.run = { _ in throw GetIdFromContactError() }
    var contact4 = Contact.unimplemented("contact-4".data(using: .utf8)!)
    contact4.getIdFromContact.run = { _ in "contact-4-id".data(using: .utf8)! }
    let contacts = [contact1, contact2, contact3, contact4]

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.searchUsers.run = { query in
      didSearchWithQuery.append(query)
      return contacts
    }

    store.send(.set(\.$focusedField, .username)) {
      $0.focusedField = .username
    }

    store.send(.set(\.$query.username, "Username")) {
      $0.query.username = "Username"
    }

    store.send(.searchTapped) {
      $0.focusedField = nil
      $0.isSearching = true
      $0.results = []
      $0.failure = nil
    }

    store.receive(.didSucceed(contacts)) {
      $0.isSearching = false
      $0.failure = nil
      $0.results = [
        .init(id: "contact-1-id".data(using: .utf8)!, contact: contact1),
        .init(id: "contact-2-id".data(using: .utf8)!, contact: contact2),
        .init(id: "contact-4-id".data(using: .utf8)!, contact: contact4)
      ]
    }
  }

  func testSearchFailure() {
    let store = TestStore(
      initialState: UserSearchState(),
      reducer: userSearchReducer,
      environment: .unimplemented
    )

    struct Failure: Error {}
    let failure = Failure()

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.searchUsers.run = { _ in throw failure }

    store.send(.searchTapped) {
      $0.focusedField = nil
      $0.isSearching = true
      $0.results = []
      $0.failure = nil
    }

    store.receive(.didFail(failure.localizedDescription)) {
      $0.isSearching = false
      $0.failure = failure.localizedDescription
      $0.results = []
    }
  }
}
