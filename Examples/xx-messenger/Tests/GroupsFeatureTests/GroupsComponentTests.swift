import ComposableArchitecture
import XCTest
@testable import GroupsFeature

final class GroupsComponentTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: GroupsComponent.State(),
      reducer: GroupsComponent()
    )

    store.send(.start)
  }
}
