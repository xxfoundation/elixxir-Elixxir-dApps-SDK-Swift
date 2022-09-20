import ComposableArchitecture
import XCTest
@testable import MyContactFeature

final class MyContactFeatureTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: MyContactState(),
      reducer: myContactReducer,
      environment: .unimplemented
    )

    store.send(.start)
  }
}
