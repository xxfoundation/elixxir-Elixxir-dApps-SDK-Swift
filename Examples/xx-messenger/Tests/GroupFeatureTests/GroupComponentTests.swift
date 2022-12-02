import ComposableArchitecture
import XCTest
import XXModels
@testable import GroupFeature

final class GroupComponentTests: XCTestCase {
  func testStart() {
    let store = TestStore(
      initialState: GroupComponent.State(
        group: .stub()
      ),
      reducer: GroupComponent()
    )

    store.send(.start)
  }
}

private extension XXModels.Group {
  static func stub() -> XXModels.Group {
    XXModels.Group(
      id: "group-id".data(using: .utf8)!,
      name: "Group name",
      leaderId: "group-leader-id".data(using: .utf8)!,
      createdAt: Date(timeIntervalSince1970: TimeInterval(86_400)),
      authStatus: .participating,
      serialized: "group-serialized".data(using: .utf8)!
    )
  }
}
