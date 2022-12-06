import AppCore
import ComposableArchitecture
import Foundation
import XXMessengerClient
import XXModels

public struct NewGroupComponent: ReducerProtocol {
  public struct State: Equatable {
    public enum Field: String, Hashable {
      case name
      case message
    }

    public init(
      contacts: IdentifiedArrayOf<XXModels.Contact> = [],
      members: IdentifiedArrayOf<XXModels.Contact> = [],
      name: String = "",
      message: String = "",
      focusedField: Field? = nil,
      isCreating: Bool = false,
      failure: String? = nil
    ) {
      self.contacts = contacts
      self.members = members
      self.name = name
      self.message = message
      self.focusedField = focusedField
      self.isCreating = isCreating
      self.failure = failure
    }

    public var contacts: IdentifiedArrayOf<XXModels.Contact>
    public var members: IdentifiedArrayOf<XXModels.Contact>
    @BindableState public var name: String
    @BindableState public var message: String
    @BindableState public var focusedField: Field?
    public var isCreating: Bool
    public var failure: String?
  }

  public enum Action: Equatable, BindableAction {
    case start
    case didFetchContacts([XXModels.Contact])
    case didSelectContact(XXModels.Contact)
    case createButtonTapped
    case didFinish
    case didFail(String)
    case binding(BindingAction<State>)
  }

  public init() {}

  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.dbManager.getDB) var db: DBManagerGetDB
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.date) var date: DateGenerator

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
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

      case .createButtonTapped:
        state.focusedField = nil
        state.isCreating = true
        state.failure = nil
        return Effect.result { [state] in
          do {
            let groupChat = try messenger.groupChat.tryGet()
            let report = try groupChat.makeGroup(
              membership: state.members.map(\.id),
              message: state.message.data(using: .utf8)!,
              name: state.name.data(using: .utf8)!
            )
            let myContactId = try messenger.e2e.tryGet().getContact().getId()
            let group = XXModels.Group(
              id: report.id,
              name: state.name,
              leaderId: myContactId,
              createdAt: date(),
              authStatus: .participating,
              serialized: try report.encode()
            )
            try db().saveGroup(group)
            if state.message.isEmpty == false {
              try db().saveMessage(.init(
                senderId: myContactId,
                recipientId: nil,
                groupId: group.id,
                date: group.createdAt,
                status: .sent,
                isUnread: false,
                text: state.message
              ))
            }
            try state.members.map {
              GroupMember(groupId: group.id, contactId: $0.id)
            }.forEach {
              try db().saveGroupMember($0)
            }
            return .success(.didFinish)
          } catch {
            return .success(.didFail(error.localizedDescription))
          }
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .didFinish:
        state.isCreating = false
        state.failure = nil
        return .none

      case .didFail(let failure):
        state.isCreating = false
        state.failure = failure
        return .none

      case .binding(_):
        return .none
      }
    }
  }
}
