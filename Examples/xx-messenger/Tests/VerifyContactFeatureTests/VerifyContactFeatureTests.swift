import ComposableArchitecture
import XCTest
@testable import VerifyContactFeature

final class VerifyContactFeatureTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: VerifyContactState(
        xxContact: .unimplemented("contact-data".data(using: .utf8)!)
      ),
      reducer: verifyContactReducer,
      environment: .unimplemented
    )

    store.send(.start)
  }
}
