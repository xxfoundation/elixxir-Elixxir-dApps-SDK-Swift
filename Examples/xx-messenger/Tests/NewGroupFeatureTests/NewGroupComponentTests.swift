import ComposableArchitecture
import XCTest
@testable import NewGroupFeature

final class NewGroupComponentTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: NewGroupComponent.State(),
      reducer: NewGroupComponent()
    )

    store.send(.start)
  }
}
