import Combine
import ComposableArchitecture
import CustomDump
import XCTest
import XXModels
@testable import GroupFeature

final class GroupComponentTests: XCTestCase {
  enum Action: Equatable {
    case didFetchGroupInfos(GroupInfo.Query)
  }

  var actions: [Action]!

  override func setUp() {
    actions = []
  }

  override func tearDown() {
    actions = nil
  }

  func testStart() {
    let groupId = "group-id".data(using: .utf8)!
    let groupInfosSubject = PassthroughSubject<[GroupInfo], Error>()

    let store = TestStore(
      initialState: GroupComponent.State(
        groupId: groupId
      ),
      reducer: GroupComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.dbManager.getDB.run = {
      var db: Database = .unimplemented
      db.fetchGroupInfosPublisher.run = { query in
        self.actions.append(.didFetchGroupInfos(query))
        return groupInfosSubject.eraseToAnyPublisher()
      }
      return db
    }

    store.send(.start)

    XCTAssertNoDifference(actions, [
      .didFetchGroupInfos(.init(groupId: groupId)),
    ])

    let groupInfo = GroupInfo.stub()
    groupInfosSubject.send([groupInfo])

    store.receive(.didFetchGroupInfo(groupInfo)) {
      $0.groupInfo = groupInfo
    }

    groupInfosSubject.send(completion: .finished)
  }
}

private extension XXModels.GroupInfo {
  static func stub() -> XXModels.GroupInfo {
    XXModels.GroupInfo(
      group: .init(
        id: "group-id".data(using: .utf8)!,
        name: "Group Name",
        leaderId: "group-leader-id".data(using: .utf8)!,
        createdAt: Date(timeIntervalSince1970: TimeInterval(86_400)),
        authStatus: .participating,
        serialized: "group-serialized".data(using: .utf8)!
      ),
      leader: .init(
        id: "group-leader-id".data(using: .utf8)!,
        username: "Group leader"
      ),
      members: [
        .init(
          id: "member-1-id".data(using: .utf8)!,
          username: "Member 1"
        ),
        .init(
          id: "member-2-id".data(using: .utf8)!,
          username: "Member 2"
        ),
      ]
    )
  }
}
