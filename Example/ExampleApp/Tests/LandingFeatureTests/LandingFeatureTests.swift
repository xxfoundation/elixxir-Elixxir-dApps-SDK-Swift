import ComposableArchitecture
import XCTest
@testable import LandingFeature

final class LandingFeatureTests: XCTestCase {
  func testViewDidLoad() throws {
    let store = TestStore(
      initialState: LandingState(),
      reducer: landingReducer,
      environment: .failing
    )

    store.send(.viewDidLoad)
  }
}
