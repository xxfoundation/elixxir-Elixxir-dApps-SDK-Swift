import ComposableArchitecture
import ContactFeature
import CustomDump
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

    var didSearchWithQuery: [MessengerSearchContacts.Query] = []

    struct GetIdFromContactError: Error {}
    struct GetFactsFromContactError: Error {}

    var contact1 = Contact.unimplemented("contact-1".data(using: .utf8)!)
    contact1.getIdFromContact.run = { _ in "contact-1-id".data(using: .utf8)! }
    contact1.getFactsFromContact.run = { _ in
      [
        Fact(type: .username, value: "contact-1-username"),
        Fact(type: .email, value: "contact-1-email"),
        Fact(type: .phone, value: "contact-1-phone"),
      ]
    }
    var contact2 = Contact.unimplemented("contact-2".data(using: .utf8)!)
    contact2.getIdFromContact.run = { _ in "contact-2-id".data(using: .utf8)! }
    contact2.getFactsFromContact.run = { _ in
      [
        Fact(type: .username, value: "contact-2-username"),
      ]
    }
    var contact3 = Contact.unimplemented("contact-3".data(using: .utf8)!)
    contact3.getIdFromContact.run = { _ in throw GetIdFromContactError() }
    contact3.getFactsFromContact.run = { _ in [] }
    var contact4 = Contact.unimplemented("contact-4".data(using: .utf8)!)
    contact4.getIdFromContact.run = { _ in "contact-4-id".data(using: .utf8)! }
    contact4.getFactsFromContact.run = { _ in throw GetFactsFromContactError() }
    let contacts = [contact1, contact2, contact3, contact4]

    store.environment.bgQueue = .immediate
    store.environment.mainQueue = .immediate
    store.environment.messenger.searchContacts.run = { query in
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

    XCTAssertNoDifference(didSearchWithQuery, [.init(username: "Username")])

    store.receive(.didSucceed(contacts)) {
      $0.isSearching = false
      $0.failure = nil
      $0.results = [
        .init(
          id: "contact-1-id".data(using: .utf8)!,
          xxContact: contact1,
          username: "contact-1-username",
          email: "contact-1-email",
          phone: "contact-1-phone"
        ),
        .init(
          id: "contact-2-id".data(using: .utf8)!,
          xxContact: contact2,
          username: "contact-2-username"
        ),
        .init(
          id: "contact-4-id".data(using: .utf8)!,
          xxContact: contact4
        )
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
    store.environment.messenger.searchContacts.run = { _ in throw failure }

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

  func testResultTapped() {
    let store = TestStore(
      initialState: UserSearchState(
        results: [
          .init(
            id: "contact-id".data(using: .utf8)!,
            xxContact: .unimplemented("contact-data".data(using: .utf8)!)
          )
        ]
      ),
      reducer: userSearchReducer,
      environment: .unimplemented
    )

    store.send(.resultTapped(id: "contact-id".data(using: .utf8)!)) {
      $0.contact = ContactState(
        id: "contact-id".data(using: .utf8)!,
        xxContact: .unimplemented("contact-data".data(using: .utf8)!)
      )
    }
  }

  func testDismissingContact() {
    let store = TestStore(
      initialState: UserSearchState(
        contact: ContactState(
          id: "contact-id".data(using: .utf8)!
        )
      ),
      reducer: userSearchReducer,
      environment: .unimplemented
    )

    store.send(.didDismissContact) {
      $0.contact = nil
    }
  }
}
