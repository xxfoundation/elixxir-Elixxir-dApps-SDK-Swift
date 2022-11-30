import Combine
import ComposableArchitecture
import CustomDump
import XCTest
import XXModels
@testable import GroupsFeature

final class GroupsComponentTests: XCTestCase {
  enum Action: Equatable {
    case didFetchGroups(XXModels.Group.Query)
  }

  var actions: [Action]!

  override func setUp() {
    actions = []
  }

  override func tearDown() {
    actions = nil
  }

  func testStart() {
    let groupsSubject = PassthroughSubject<[XXModels.Group], Error>()

    let store = TestStore(
      initialState: GroupsComponent.State(),
      reducer: GroupsComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.dbManager.getDB.run = {
      var db: Database = .unimplemented
      db.fetchGroupsPublisher.run = { query in
        self.actions.append(.didFetchGroups(query))
        return groupsSubject.eraseToAnyPublisher()
      }
      return db
    }

    store.send(.start)

    XCTAssertNoDifference(actions, [
      .didFetchGroups(.init())
    ])

    let groups: [XXModels.Group] = [
      .stub(1),
      .stub(2),
      .stub(3),
    ]
    groupsSubject.send(groups)

    store.receive(.didFetchGroups(groups)) {
      $0.groups = IdentifiedArray(uniqueElements: groups)
    }

    groupsSubject.send(completion: .finished)
  }

  func testSelectGroup() {
    let store = TestStore(
      initialState: GroupsComponent.State(
        groups: IdentifiedArray(uniqueElements: [
          .stub(1),
          .stub(2),
          .stub(3),
        ])
      ),
      reducer: GroupsComponent()
    )

    store.send(.didSelectGroup(.stub(2)))
  }
}

private extension XXModels.Group {
  static func stub(_ id: Int) -> XXModels.Group {
    XXModels.Group(
      id: "group-\(id)-id".data(using: .utf8)!,
      name: "Group \(id)",
      leaderId: "group-\(id)-leader-id".data(using: .utf8)!,
      createdAt: Date(timeIntervalSince1970: TimeInterval(id * 86_400)),
      authStatus: .participating,
      serialized: "group-\(id)-serialized".data(using: .utf8)!
    )
  }
}
