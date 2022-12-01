import AppCore
import ComposableArchitecture
import Foundation
import XXModels

public struct NewGroupComponent: ReducerProtocol {
  public struct State: Equatable {
    public init(
      contacts: IdentifiedArrayOf<XXModels.Contact> = []
    ) {
      self.contacts = contacts
    }

    public var contacts: IdentifiedArrayOf<XXModels.Contact>
  }

  public enum Action: Equatable {
    case start
    case didFetchContacts([XXModels.Contact])
    case didFinish
  }

  public init() {}

  @Dependency(\.app.dbManager.getDB) var db: DBManagerGetDB
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .start:
      return Effect
        .catching { try db() }
        .flatMap { $0.fetchContactsPublisher(.init()) }
        .assertNoFailure()
        .map(Action.didFetchContacts)
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

    case .didFetchContacts(let contacts):
      state.contacts = IdentifiedArray(uniqueElements: contacts)
      return .none

    case .didFinish:
      return .none
    }
  }
}
