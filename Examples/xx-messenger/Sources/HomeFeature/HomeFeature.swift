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
    register: RegisterState? = nil
  ) {
    self.failure = failure
    self.register = register
  }

  @BindableState public var failure: String?
  @BindableState public var register: RegisterState?
}

public enum HomeAction: Equatable, BindableAction {
  case start
  case binding(BindingAction<HomeState>)
  case register(RegisterAction)
}

public struct HomeEnvironment {
  public init(
    messenger: Messenger,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>,
    register: @escaping () -> RegisterEnvironment
  ) {
    self.messenger = messenger
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
    self.register = register
  }

  public var messenger: Messenger
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
  public var register: () -> RegisterEnvironment
}

extension HomeEnvironment {
  public static let unimplemented = HomeEnvironment(
    messenger: .unimplemented,
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
