import ComposableArchitecture
import XCTest
@testable import SendRequestFeature

final class SendRequestFeatureTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: SendRequestState(),
      reducer: sendRequestReducer,
      environment: .unimplemented
    )

    store.send(.start)
  }
}
