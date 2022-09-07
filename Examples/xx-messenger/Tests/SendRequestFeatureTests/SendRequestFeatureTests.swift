import ComposableArchitecture
import XCTest
@testable import SendRequestFeature

final class SendRequestFeatureTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: SendRequestState(
        contact: .unimplemented("contact-data".data(using: .utf8)!)
      ),
      reducer: sendRequestReducer,
      environment: .unimplemented
    )

    store.send(.start)
  }
}
