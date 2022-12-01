import AppCore
import ComposableArchitecture
import Foundation
import XXMessengerClient
import XXModels

public struct NewGroupComponent: ReducerProtocol {
  public struct State: Equatable {
    public init(
      contacts: IdentifiedArrayOf<XXModels.Contact> = [],
      members: IdentifiedArrayOf<XXModels.Contact> = []
    ) {
      self.contacts = contacts
      self.members = members
    }

    public var contacts: IdentifiedArrayOf<XXModels.Contact>
    public var members: IdentifiedArrayOf<XXModels.Contact>
  }

  public enum Action: Equatable {
    case start
    case didFetchContacts([XXModels.Contact])
    case didSelectContact(XXModels.Contact)
    case didFinish
  }

  public init() {}

  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.dbManager.getDB) var db: DBManagerGetDB
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .start:
      let myId = try? messenger.e2e.tryGet().getContact().getId()
      return Effect
        .catching { try db() }
        .flatMap { $0.fetchContactsPublisher(.init()) }
        .assertNoFailure()
        .map { $0.filter { $0.id != myId } }
        .map(Action.didFetchContacts)
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

    case .didFetchContacts(let contacts):
      state.contacts = IdentifiedArray(uniqueElements: contacts)
      return .none

    case .didSelectContact(let contact):
      if state.members.contains(contact) {
        state.members.remove(contact)
      } else {
        state.members.append(contact)
      }
      return .none

    case .didFinish:
      return .none
    }
  }
}
