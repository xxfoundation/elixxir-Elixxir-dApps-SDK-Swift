import ComposableArchitecture
import XCTest
@testable import VerifyContactFeature

final class VerifyContactFeatureTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: VerifyContactState(),
      reducer: verifyContactReducer,
      environment: .unimplemented
    )

    store.send(.start)
  }
}
