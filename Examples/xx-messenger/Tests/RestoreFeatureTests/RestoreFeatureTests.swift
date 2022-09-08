import ComposableArchitecture
import XCTest
@testable import RestoreFeature

final class RestoreFeatureTests: XCTestCase {
  func testFinish() {
    let store = TestStore(
      initialState: RestoreState(),
      reducer: restoreReducer,
      environment: .unimplemented
    )

    store.send(.finished)
  }
}
