import AppCore
import ComposableArchitecture
import Foundation
import XXModels

public struct GroupsComponent: ReducerProtocol {
  public struct State: Equatable {
    public init(
      groups: IdentifiedArrayOf<Group> = []
    ) {
      self.groups = groups
    }

    public var groups: IdentifiedArrayOf<XXModels.Group> = []
  }

  public enum Action: Equatable {
    case start
    case didFetchGroups([XXModels.Group])
    case didSelectGroup(XXModels.Group)
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
          .flatMap { $0.fetchGroupsPublisher.callAsFunction(.init()) }
          .assertNoFailure()
          .map(Action.didFetchGroups)
          .subscribe(on: bgQueue)
          .receive(on: mainQueue)
          .eraseToEffect()

      case .didFetchGroups(let groups):
        state.groups = IdentifiedArray(uniqueElements: groups)
        return .none

      case .didSelectGroup(_):
        return .none
      }
    }
  }
}
