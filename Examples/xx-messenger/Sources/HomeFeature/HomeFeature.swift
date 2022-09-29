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

public struct HomeState: Equatable {
  public init(
    failure: String? = nil,
    isNetworkHealthy: Bool? = nil,
    networkNodesReport: NodeRegistrationReport? = nil,
    isDeletingAccount: Bool = false,
    alert: AlertState<HomeAction>? = nil,
    register: RegisterState? = nil,
    contacts: ContactsState? = nil,
    userSearch: UserSearchState? = nil,
    backup: BackupState? = nil
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
  public var alert: AlertState<HomeAction>?
  public var register: RegisterState?
  public var contacts: ContactsState?
  public var userSearch: UserSearchState?
  public var backup: BackupState?
}

public enum HomeAction: Equatable {
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
  case register(RegisterAction)
  case contacts(ContactsAction)
  case userSearch(UserSearchAction)
  case backup(BackupAction)
}

public struct HomeEnvironment {
  public init(
    messenger: Messenger,
    dbManager: DBManager,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>,
    register: @escaping () -> RegisterEnvironment,
    contacts: @escaping () -> ContactsEnvironment,
    userSearch: @escaping () -> UserSearchEnvironment,
    backup: @escaping () -> BackupEnvironment
  ) {
    self.messenger = messenger
    self.dbManager = dbManager
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
    self.register = register
    self.contacts = contacts
    self.userSearch = userSearch
    self.backup = backup
  }

  public var messenger: Messenger
  public var dbManager: DBManager
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
  public var register: () -> RegisterEnvironment
  public var contacts: () -> ContactsEnvironment
  public var userSearch: () -> UserSearchEnvironment
  public var backup: () -> BackupEnvironment
}

extension HomeEnvironment {
  public static let unimplemented = HomeEnvironment(
    messenger: .unimplemented,
    dbManager: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented,
    register: { .unimplemented },
    contacts: { .unimplemented },
    userSearch: { .unimplemented },
    backup: { .unimplemented }
  )
}

public let homeReducer = Reducer<HomeState, HomeAction, HomeEnvironment>
{ state, action, env in
  enum NetworkHealthEffectId {}
  enum NetworkNodesEffectId {}

  switch action {
  case .messenger(.start):
    return .merge(
      Effect(value: .networkMonitor(.stop)),
      Effect.result {
        do {
          try env.messenger.start()

          if env.messenger.isConnected() == false {
            try env.messenger.connect()
          }

          if env.messenger.isListeningForMessages() == false {
            try env.messenger.listenForMessages()
          }

          if env.messenger.isLoggedIn() == false {
            if try env.messenger.isRegistered() == false {
              return .success(.messenger(.didStartUnregistered))
            }
            try env.messenger.logIn()
          }

          if !env.messenger.isBackupRunning() {
            try? env.messenger.resumeBackup()
          }

          return .success(.messenger(.didStartRegistered))
        } catch {
          return .success(.messenger(.failure(error as NSError)))
        }
      }
    )
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .messenger(.didStartUnregistered):
    state.register = RegisterState()
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
        let cancellable = env.messenger.cMix()?.addHealthCallback(callback)
        return AnyCancellable { cancellable?.cancel() }
      }
        .cancellable(id: NetworkHealthEffectId.self, cancelInFlight: true),
      Effect.timer(
        id: NetworkNodesEffectId.self,
        every: .seconds(2),
        on: env.bgQueue
      )
      .compactMap { _ in try? env.messenger.cMix()?.getNodeRegistrationStatus() }
        .map { HomeAction.networkMonitor(.nodes($0)) }
        .eraseToEffect()
    )
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
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
        let contactId = try env.messenger.e2e.tryGet().getContact().getId()
        let contact = try env.dbManager.getDB().fetchContacts(.init(id: [contactId])).first
        if let username = contact?.username {
          let ud = try env.messenger.ud.tryGet()
          try ud.permanentDeleteAccount(username: Fact(type: .username, value: username))
        }
        try env.messenger.destroy()
        try env.dbManager.removeDB()
        return .success(.deleteAccount(.success))
      } catch {
        return .success(.deleteAccount(.failure(error as NSError)))
      }
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
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
    state.userSearch = UserSearchState()
    return .none

  case .didDismissUserSearch:
    state.userSearch = nil
    return .none

  case .contactsButtonTapped:
    state.contacts = ContactsState()
    return .none

  case .didDismissContacts:
    state.contacts = nil
    return .none

  case .register(.finished):
    state.register = nil
    return Effect(value: .messenger(.start))

  case .backupButtonTapped:
    state.backup = BackupState()
    return .none

  case .didDismissBackup:
    state.backup = nil
    return .none

  case .register(_), .contacts(_), .userSearch(_), .backup(_):
    return .none
  }
}
.presenting(
  registerReducer,
  state: .keyPath(\.register),
  id: .notNil(),
  action: /HomeAction.register,
  environment: { $0.register() }
)
.presenting(
  contactsReducer,
  state: .keyPath(\.contacts),
  id: .notNil(),
  action: /HomeAction.contacts,
  environment: { $0.contacts() }
)
.presenting(
  userSearchReducer,
  state: .keyPath(\.userSearch),
  id: .notNil(),
  action: /HomeAction.userSearch,
  environment: { $0.userSearch() }
)
.presenting(
  backupReducer,
  state: .keyPath(\.backup),
  id: .notNil(),
  action: /HomeAction.backup,
  environment: { $0.backup() }
)
