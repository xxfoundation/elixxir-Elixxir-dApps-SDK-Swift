import AppCore
import BackupFeature
import Combine
import ComposableArchitecture
import ComposablePresentation
import ContactsFeature
import Foundation
import RegisterFeature
import UserSearchFeature
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct HomeComponent: ReducerProtocol {
  public struct State: Equatable {
    public init(
      failure: String? = nil,
      isNetworkHealthy: Bool? = nil,
      networkNodesReport: NodeRegistrationReport? = nil,
      isDeletingAccount: Bool = false,
      alert: AlertState<Action>? = nil,
      register: RegisterComponent.State? = nil,
      contacts: ContactsComponent.State? = nil,
      userSearch: UserSearchComponent.State? = nil,
      backup: BackupComponent.State? = nil
    ) {
      self.failure = failure
      self.isNetworkHealthy = isNetworkHealthy
      self.isDeletingAccount = isDeletingAccount
      self.alert = alert
      self.register = register
      self.contacts = contacts
      self.userSearch = userSearch
      self.backup = backup
    }

    public var failure: String?
    public var isNetworkHealthy: Bool?
    public var networkNodesReport: NodeRegistrationReport?
    public var isDeletingAccount: Bool
    public var alert: AlertState<Action>?
    public var register: RegisterComponent.State?
    public var contacts: ContactsComponent.State?
    public var userSearch: UserSearchComponent.State?
    public var backup: BackupComponent.State?
  }

  public enum Action: Equatable {
    public enum Messenger: Equatable {
      case start
      case didStartRegistered
      case didStartUnregistered
      case failure(NSError)
    }

    public enum NetworkMonitor: Equatable {
      case start
      case stop
      case health(Bool)
      case nodes(NodeRegistrationReport)
    }

    public enum DeleteAccount: Equatable {
      case buttonTapped
      case confirmed
      case success
      case failure(NSError)
    }

    case messenger(Messenger)
    case networkMonitor(NetworkMonitor)
    case deleteAccount(DeleteAccount)
    case didDismissAlert
    case didDismissRegister
    case userSearchButtonTapped
    case didDismissUserSearch
    case contactsButtonTapped
    case didDismissContacts
    case backupButtonTapped
    case didDismissBackup
    case register(RegisterComponent.Action)
    case contacts(ContactsComponent.Action)
    case userSearch(UserSearchComponent.Action)
    case backup(BackupComponent.Action)
  }

  public init() {}

  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.dbManager) var dbManager: DBManager
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      enum NetworkHealthEffectId {}
      enum NetworkNodesEffectId {}

      let messenger = self.messenger

      switch action {
      case .messenger(.start):
        return .merge(
          Effect(value: .networkMonitor(.stop)),
          Effect.result {
            do {
              try messenger.start()

              if messenger.isConnected() == false {
                try messenger.connect()
              }

              if messenger.isListeningForMessages() == false {
                try messenger.listenForMessages()
              }

              if messenger.isFileTransferRunning() == false {
                try messenger.startFileTransfer()
              }

              if messenger.isGroupChatRunning() == false {
                try messenger.startGroupChat()
              }

              if messenger.isLoggedIn() == false {
                if try messenger.isRegistered() == false {
                  return .success(.messenger(.didStartUnregistered))
                }
                try messenger.logIn()
              }

              if !messenger.isBackupRunning() {
                try? messenger.resumeBackup()
              }

              return .success(.messenger(.didStartRegistered))
            } catch {
              return .success(.messenger(.failure(error as NSError)))
            }
          }
        )
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .messenger(.didStartUnregistered):
        state.register = RegisterComponent.State()
        return .none

      case .messenger(.didStartRegistered):
        return Effect(value: .networkMonitor(.start))

      case .messenger(.failure(let error)):
        state.failure = error.localizedDescription
        return .none

      case .networkMonitor(.start):
        return .merge(
          Effect.run { subscriber in
            let callback = HealthCallback { isHealthy in
              subscriber.send(.networkMonitor(.health(isHealthy)))
            }
            let cancellable = messenger.cMix()?.addHealthCallback(callback)
            return AnyCancellable { cancellable?.cancel() }
          }
            .cancellable(id: NetworkHealthEffectId.self, cancelInFlight: true),
          Effect.timer(
            id: NetworkNodesEffectId.self,
            every: .seconds(2),
            on: bgQueue
          )
          .compactMap { _ in try? messenger.cMix()?.getNodeRegistrationStatus() }
            .map { Action.networkMonitor(.nodes($0)) }
            .eraseToEffect()
        )
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .networkMonitor(.stop):
        state.isNetworkHealthy = nil
        state.networkNodesReport = nil
        return .merge(
          .cancel(id: NetworkHealthEffectId.self),
          .cancel(id: NetworkNodesEffectId.self)
        )

      case .networkMonitor(.health(let isHealthy)):
        state.isNetworkHealthy = isHealthy
        return .none

      case .networkMonitor(.nodes(let report)):
        state.networkNodesReport = report
        return .none

      case .deleteAccount(.buttonTapped):
        state.alert = .confirmAccountDeletion()
        return .none

      case .deleteAccount(.confirmed):
        state.isDeletingAccount = true
        return .result {
          do {
            let contactId = try messenger.e2e.tryGet().getContact().getId()
            let contact = try dbManager.getDB().fetchContacts(.init(id: [contactId])).first
            if let username = contact?.username {
              let ud = try messenger.ud.tryGet()
              try ud.permanentDeleteAccount(username: Fact(type: .username, value: username))
            }
            try messenger.destroy()
            try dbManager.removeDB()
            return .success(.deleteAccount(.success))
          } catch {
            return .success(.deleteAccount(.failure(error as NSError)))
          }
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .deleteAccount(.success):
        state.isDeletingAccount = false
        return .none

      case .deleteAccount(.failure(let error)):
        state.isDeletingAccount = false
        state.alert = .accountDeletionFailed(error)
        return .none

      case .didDismissAlert:
        state.alert = nil
        return .none

      case .didDismissRegister:
        state.register = nil
        return .none

      case .userSearchButtonTapped:
        state.userSearch = UserSearchComponent.State()
        return .none

      case .didDismissUserSearch:
        state.userSearch = nil
        return .none

      case .contactsButtonTapped:
        state.contacts = ContactsComponent.State()
        return .none

      case .didDismissContacts:
        state.contacts = nil
        return .none

      case .register(.finished):
        state.register = nil
        return Effect(value: .messenger(.start))

      case .backupButtonTapped:
        state.backup = BackupComponent.State()
        return .none

      case .didDismissBackup:
        state.backup = nil
        return .none

      case .register(_), .contacts(_), .userSearch(_), .backup(_):
        return .none
      }
    }
    .presenting(
      state: .keyPath(\.register),
      id: .notNil(),
      action: /Action.register,
      presented: { RegisterComponent() }
    )
    .presenting(
      state: .keyPath(\.contacts),
      id: .notNil(),
      action: /Action.contacts,
      presented: { ContactsComponent() }
    )
    .presenting(
      state: .keyPath(\.userSearch),
      id: .notNil(),
      action: /Action.userSearch,
      presented: { UserSearchComponent() }
    )
    .presenting(
      state: .keyPath(\.backup),
      id: .notNil(),
      action: /Action.backup,
      presented: { BackupComponent() }
    )
  }
}
