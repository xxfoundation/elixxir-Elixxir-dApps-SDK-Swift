import AppCore
import ChatFeature
import ComposableArchitecture
import ComposablePresentation
import Foundation
import XXMessengerClient
import XXModels

public struct GroupComponent: ReducerProtocol {
  public struct State: Equatable {
    public init(
      groupId: XXModels.Group.ID,
      groupInfo: XXModels.GroupInfo? = nil,
      isJoining: Bool = false,
      joinFailure: String? = nil,
      chat: ChatComponent.State? = nil
    ) {
      self.groupId = groupId
      self.groupInfo = groupInfo
      self.isJoining = isJoining
      self.joinFailure = joinFailure
      self.chat = chat
    }

    public var groupId: XXModels.Group.ID
    public var groupInfo: XXModels.GroupInfo?
    public var isJoining: Bool
    public var joinFailure: String?
    public var chat: ChatComponent.State?
  }

  public enum Action: Equatable {
    case start
    case didFetchGroupInfo(XXModels.GroupInfo?)
    case joinButtonTapped
    case didJoin
    case didFailToJoin(String)
    case chatButtonTapped
    case didDismissChat
    case chat(ChatComponent.Action)
  }

  public init() {}

  @Dependency(\.app.messenger) var messenger: Messenger
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

      case .joinButtonTapped:
        guard let info = state.groupInfo else { return .none }
        state.isJoining = true
        state.joinFailure = nil
        return Effect.result {
          do {
            let groupChat = try messenger.groupChat.tryGet()
            try groupChat.joinGroup(serializedGroupData: info.group.serialized)
            var group = info.group
            group.authStatus = .participating
            try db().saveGroup(group)
            return .success(.didJoin)
          } catch {
            return .success(.didFailToJoin(error.localizedDescription))
          }
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .didJoin:
        state.isJoining = false
        state.joinFailure = nil
        return .none

      case .didFailToJoin(let failure):
        state.isJoining = false
        state.joinFailure = failure
        return .none

      case .chatButtonTapped:
        state.chat = ChatComponent.State(id: .group(state.groupId))
        return .none

      case .didDismissChat:
        state.chat = nil
        return .none

      case .chat(_):
        return .none
      }
    }
    .presenting(
      state: .keyPath(\.chat),
      id: .notNil(),
      action: /Action.chat,
      presented: { ChatComponent() }
    )
  }
}
