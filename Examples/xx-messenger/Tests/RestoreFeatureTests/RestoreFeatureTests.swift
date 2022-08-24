import ComposableArchitecture
import XCTest
@testable import RestoreFeature

@MainActor
final class RestoreFeatureTests: XCTestCase {
  func testFinish() async throws {
    let store = TestStore(
      initialState: RestoreState(),
      reducer: restoreReducer,
      environment: .unimplemented
    )

    await store.send(.finished)
  }
}
