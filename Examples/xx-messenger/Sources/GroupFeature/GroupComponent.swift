import AppCore
import ComposableArchitecture
import Foundation
import XXModels

public struct GroupComponent: ReducerProtocol {
  public struct State: Equatable {
    public init(
      groupId: XXModels.Group.ID,
      groupInfo: XXModels.GroupInfo? = nil
    ) {
      self.groupId = groupId
      self.groupInfo = groupInfo
    }

    public var groupId: XXModels.Group.ID
    public var groupInfo: XXModels.GroupInfo?
  }

  public enum Action: Equatable {
    case start
    case didFetchGroupInfo(XXModels.GroupInfo?)
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
          .flatMap { [state] in
            let query = GroupInfo.Query(groupId: state.groupId)
            return $0.fetchGroupInfosPublisher(query).map(\.first)
          }
          .assertNoFailure()
          .map(Action.didFetchGroupInfo)
          .subscribe(on: bgQueue)
          .receive(on: mainQueue)
          .eraseToEffect()

      case .didFetchGroupInfo(let groupInfo):
        state.groupInfo = groupInfo
        return .none
      }
    }
  }
}
