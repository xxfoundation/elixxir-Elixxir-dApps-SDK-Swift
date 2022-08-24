import ComposableArchitecture
import HomeFeature
import XCTest
@testable import AppFeature

@MainActor
final class AppFeatureTests: XCTestCase {
  func testLaunchFinished() async throws {
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: .unimplemented
    )

    await store.send(.launch(.finished)) {
      $0.screen = .home(HomeState())
    }
  }
}
