import ComposableArchitecture
import XCTest
@testable import ContactFeature

final class ContactSendRequestFeatureTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: ContactSendRequestState(),
      reducer: contactSendRequestReducer,
      environment: .unimplemented
    )

    store.send(.start)
  }
}
