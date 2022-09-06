import ComposableArchitecture
import XCTest
import XXClient
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
        contact: contact
      ),
      reducer: userSearchResultReducer,
      environment: .unimplemented
    )

    store.send(.start) {
      $0.username = "contact-username"
      $0.email = "contact-email"
      $0.phone = "contact-phone"
    }
  }
}
