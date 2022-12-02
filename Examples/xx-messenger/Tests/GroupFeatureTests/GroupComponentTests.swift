import Combine
import ComposableArchitecture
import CustomDump
import XCTest
import XXClient
import XXMessengerClient
import XXModels
@testable import GroupFeature

final class GroupComponentTests: XCTestCase {
  enum Action: Equatable {
    case didFetchGroupInfos(GroupInfo.Query)
    case didJoinGroup(Data)
    case didSaveGroup(XXModels.Group)
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

  func testJoinGroup() {
    var groupInfo = GroupInfo.stub()
    groupInfo.group.authStatus = .pending

    let store = TestStore(
      initialState: GroupComponent.State(
        groupId: groupInfo.group.id,
        groupInfo: groupInfo
      ),
      reducer: GroupComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.groupChat.get = {
      var groupChat: GroupChat = .unimplemented
      groupChat.joinGroup.run = { serializedGroupData in
        self.actions.append(.didJoinGroup(serializedGroupData))
      }
      return groupChat
    }
    store.dependencies.app.dbManager.getDB.run = {
      var db: Database = .unimplemented
      db.saveGroup.run = { group in
        self.actions.append(.didSaveGroup(group))
        return group
      }
      return db
    }

    store.send(.joinButtonTapped) {
      $0.isJoining = true
    }

    XCTAssertNoDifference(actions, [
      .didJoinGroup(groupInfo.group.serialized),
      .didSaveGroup({
        var group = groupInfo.group
        group.authStatus = .participating
        return group
      }())
    ])

    store.receive(.didJoin) {
      $0.isJoining = false
    }
  }

  func testJoinGroupFailure() {
    let groupInfo = GroupInfo.stub()
    struct Failure: Error {}
    let failure = Failure()

    let store = TestStore(
      initialState: GroupComponent.State(
        groupId: groupInfo.group.id,
        groupInfo: groupInfo
      ),
      reducer: GroupComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.messenger.groupChat.get = {
      var groupChat: GroupChat = .unimplemented
      groupChat.joinGroup.run = { _ in throw failure }
      return groupChat
    }

    store.send(.joinButtonTapped) {
      $0.isJoining = true
    }

    store.receive(.didFailToJoin(failure.localizedDescription)) {
      $0.isJoining = false
      $0.joinFailure = failure.localizedDescription
    }
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
