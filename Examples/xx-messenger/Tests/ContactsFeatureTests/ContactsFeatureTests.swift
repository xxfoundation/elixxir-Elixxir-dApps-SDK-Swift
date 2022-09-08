import ComposableArchitecture
import XCTest
@testable import ContactsFeature

final class ContactsFeatureTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: ContactsState(),
      reducer: contactsReducer,
      environment: .unimplemented
    )

    store.send(.start)
  }
}
