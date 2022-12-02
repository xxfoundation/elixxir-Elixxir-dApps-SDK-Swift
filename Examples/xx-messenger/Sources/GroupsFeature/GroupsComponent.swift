import AppCore
import ComposableArchitecture
import ComposablePresentation
import Foundation
import GroupFeature
import NewGroupFeature
import XXModels

public struct GroupsComponent: ReducerProtocol {
  public struct State: Equatable {
    public init(
      groups: IdentifiedArrayOf<Group> = [],
      newGroup: NewGroupComponent.State? = nil,
      group: GroupComponent.State? = nil
    ) {
      self.groups = groups
      self.newGroup = newGroup
      self.group = group
    }

    public var groups: IdentifiedArrayOf<XXModels.Group> = []
    public var newGroup: NewGroupComponent.State?
    public var group: GroupComponent.State?
  }

  public enum Action: Equatable {
    case start
    case didFetchGroups([XXModels.Group])
    case didSelectGroup(XXModels.Group)
    case didDismissGroup
    case newGroupButtonTapped
    case newGroupDismissed
    case newGroup(NewGroupComponent.Action)
    case group(GroupComponent.Action)
  }

  public init() {}

  @Dependency(\.app.dbManager.getDB) var db: DBManagerGetDB
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .start:
        return Effect
          .catching { try db() }
          .flatMap { $0.fetchGroupsPublisher(.init()) }
          .assertNoFailure()
          .map(Action.didFetchGroups)
          .subscribe(on: bgQueue)
          .receive(on: mainQueue)
          .eraseToEffect()

      case .didFetchGroups(let groups):
        state.groups = IdentifiedArray(uniqueElements: groups)
        return .none

      case .didSelectGroup(let group):
        state.group = GroupComponent.State(group: group)
        return .none

      case .didDismissGroup:
        state.group = nil
        return .none

      case .newGroupButtonTapped:
        state.newGroup = NewGroupComponent.State()
        return .none

      case .newGroupDismissed:
        state.newGroup = nil
        return .none

      case .newGroup(.didFinish):
        state.newGroup = nil
        return .none

      case .newGroup(_), .group(_):
        return .none
      }
    }
    .presenting(
      state: .keyPath(\.newGroup),
      id: .notNil(),
      action: /Action.newGroup,
      presented: { NewGroupComponent() }
    )
    .presenting(
      state: .keyPath(\.group),
      id: .notNil(),
      action: /Action.group,
      presented: { GroupComponent() }
    )
  }
}
