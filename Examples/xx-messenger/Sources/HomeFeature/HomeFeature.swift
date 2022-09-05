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
    register: RegisterState? = nil,
    alert: AlertState<HomeAction>? = nil,
    isDeletingAccount: Bool = false
  ) {
    self.failure = failure
    self.register = register
    self.alert = alert
    self.isDeletingAccount = isDeletingAccount
  }

  @BindableState public var failure: String?
  @BindableState public var register: RegisterState?
  @BindableState public var alert: AlertState<HomeAction>?
  @BindableState public var isDeletingAccount: Bool
}

public enum HomeAction: Equatable, BindableAction {
  case start
  case deleteAccountButtonTapped
  case deleteAccountConfirmed
  case didDeleteAccount
  case binding(BindingAction<HomeState>)
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
  switch action {
  case .start:
    return .run { subscriber in
      do {
        try env.messenger.start()

        if env.messenger.isConnected() == false {
          try env.messenger.connect()
        }

        if env.messenger.isLoggedIn() == false {
          if try env.messenger.isRegistered() == false {
            subscriber.send(.set(\.$register, RegisterState()))
            subscriber.send(completion: .finished)
            return AnyCancellable {}
          }
          try env.messenger.logIn()
        }
      } catch {
        subscriber.send(.set(\.$failure, error.localizedDescription))
      }
      subscriber.send(completion: .finished)
      return AnyCancellable {}
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .deleteAccountButtonTapped:
    state.alert = .confirmAccountDeletion()
    return .none

  case .deleteAccountConfirmed:
    state.isDeletingAccount = true
    return .run { subscriber in
      do {
        let contactId = try env.messenger.e2e.tryGet().getContact().getId()
        let contact = try env.db().fetchContacts(.init(id: [contactId])).first
        if let username = contact?.username {
          let ud = try env.messenger.ud.tryGet()
          try ud.permanentDeleteAccount(username: Fact(fact: username, type: 0))
        }
        try env.messenger.destroy()
        try env.db().drop()
        subscriber.send(.didDeleteAccount)
      } catch {
        subscriber.send(.set(\.$isDeletingAccount, false))
        subscriber.send(.set(\.$alert, .accountDeletionFailed(error)))
      }
      subscriber.send(completion: .finished)
      return AnyCancellable {}
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .didDeleteAccount:
    state.isDeletingAccount = false
    return .none

  case .register(.finished):
    state.register = nil
    return Effect(value: .start)

  case .binding(_), .register(_):
    return .none
  }
}
.binding()
.presenting(
  registerReducer,
  state: .keyPath(\.register),
  id: .notNil(),
  action: /HomeAction.register,
  environment: { $0.register() }
)
