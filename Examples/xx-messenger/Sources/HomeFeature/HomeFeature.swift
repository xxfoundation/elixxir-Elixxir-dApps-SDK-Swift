import AppCore
import Combine
import ComposableArchitecture
import ComposablePresentation
import Foundation
import RegisterFeature
import XXClient
import XXMessengerClient

public struct HomeState: Equatable {
  public init(
    failure: String? = nil,
    isNetworkHealthy: Bool? = nil,
    isDeletingAccount: Bool = false,
    alert: AlertState<HomeAction>? = nil,
    register: RegisterState? = nil
  ) {
    self.failure = failure
    self.isNetworkHealthy = isNetworkHealthy
    self.isDeletingAccount = isDeletingAccount
    self.alert = alert
    self.register = register
  }

  public var failure: String?
  public var isNetworkHealthy: Bool?
  public var isDeletingAccount: Bool
  public var alert: AlertState<HomeAction>?
  public var register: RegisterState?
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
  case register(RegisterAction)
}

public struct HomeEnvironment {
  public init(
    messenger: Messenger,
    db: DBManagerGetDB,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>,
    register: @escaping () -> RegisterEnvironment
  ) {
    self.messenger = messenger
    self.db = db
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
    self.register = register
  }

  public var messenger: Messenger
  public var db: DBManagerGetDB
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
  public var register: () -> RegisterEnvironment
}

extension HomeEnvironment {
  public static let unimplemented = HomeEnvironment(
    messenger: .unimplemented,
    db: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented,
    register: { .unimplemented }
  )
}

public let homeReducer = Reducer<HomeState, HomeAction, HomeEnvironment>
{ state, action, env in
  enum NetworkHealthEffectId {}

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

          if env.messenger.isLoggedIn() == false {
            if try env.messenger.isRegistered() == false {
              return .success(.messenger(.didStartUnregistered))
            }
            try env.messenger.logIn()
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
    return .run { subscriber in
      let callback = HealthCallback { isHealthy in
        subscriber.send(.networkMonitor(.health(isHealthy)))
      }
      let cancellable = env.messenger.cMix()?.addHealthCallback(callback)
      return AnyCancellable { cancellable?.cancel() }
    }
    .cancellable(id: NetworkHealthEffectId.self, cancelInFlight: true)
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .networkMonitor(.stop):
    state.isNetworkHealthy = nil
    return .cancel(id: NetworkHealthEffectId.self)

  case .networkMonitor(.health(let isHealthy)):
    state.isNetworkHealthy = isHealthy
    return .none

  case .deleteAccount(.buttonTapped):
    state.alert = .confirmAccountDeletion()
    return .none

  case .deleteAccount(.confirmed):
    state.isDeletingAccount = true
    return .result {
      do {
        let contactId = try env.messenger.e2e.tryGet().getContact().getId()
        let contact = try env.db().fetchContacts(.init(id: [contactId])).first
        if let username = contact?.username {
          let ud = try env.messenger.ud.tryGet()
          try ud.permanentDeleteAccount(username: Fact(fact: username, type: 0))
        }
        try env.messenger.destroy()
        try env.db().drop()
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

  case .register(.finished):
    state.register = nil
    return Effect(value: .messenger(.start))

  case .register(_):
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
