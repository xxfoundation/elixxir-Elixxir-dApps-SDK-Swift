import ComposableArchitecture
import SwiftUI
import XXMessengerClient

public struct RegisterState: Equatable {
  public enum Field: String, Hashable {
    case username
  }

  public init(
    focusedField: Field? = nil,
    username: String = "",
    isRegistering: Bool = false
  ) {
    self.focusedField = focusedField
    self.username = username
    self.isRegistering = isRegistering
  }

  @BindableState public var focusedField: Field?
  @BindableState public var username: String
  public var isRegistering: Bool
  public var failure: String?
}

public enum RegisterAction: Equatable, BindableAction {
  case registerTapped
  case failed(String)
  case finished
  case binding(BindingAction<RegisterState>)
}

public struct RegisterEnvironment {
  public init(
    messenger: Messenger,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.messenger = messenger
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
  }

  public var messenger: Messenger
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
}

extension RegisterEnvironment {
  public static let unimplemented = RegisterEnvironment(
    messenger: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented
  )
}

public let registerReducer = Reducer<RegisterState, RegisterAction, RegisterEnvironment>
{ state, action, env in
  switch action {
  case .binding(_):
    return .none

  case .registerTapped:
    state.focusedField = nil
    state.isRegistering = true
    state.failure = nil
    return .future { [username = state.username] fulfill in
      do {
        try env.messenger.register(username: username)
        fulfill(.success(.finished))
      }
      catch {
        fulfill(.success(.failed(error.localizedDescription)))
      }
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .failed(let failure):
    state.isRegistering = false
    state.failure = failure
    return .none

  case .finished:
    return .none
  }
}
.binding()
