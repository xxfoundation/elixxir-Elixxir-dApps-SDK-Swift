import ComposableArchitecture
import XCTest
@testable import ContactFeature

final class ContactFeatureTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: ContactState(),
      reducer: contactReducer,
      environment: .unimplemented
    )

    store.send(.start)
  }
}
