import ComposableArchitecture
import XCTest
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

    store.send(.start)
  }
}
