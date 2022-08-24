import ComposableArchitecture
import XCTest
@testable import HomeFeature

@MainActor
final class HomeFeatureTests: XCTestCase {
  func testStart() async throws {
    let store = TestStore(
      initialState: HomeState(),
      reducer: homeReducer,
      environment: .unimplemented
    )

    await store.send(.start)
  }
}
