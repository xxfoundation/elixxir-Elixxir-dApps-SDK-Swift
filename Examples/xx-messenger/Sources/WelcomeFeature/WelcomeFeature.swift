import ComposableArchitecture
import SwiftUI
import XXMessengerClient

public struct WelcomeState: Equatable {
  public init(
    isCreatingCMix: Bool = false,
    failure: String? = nil
  ) {
    self.isCreatingAccount = isCreatingCMix
    self.failure = failure
  }

  public var isCreatingAccount: Bool
  public var failure: String?
}

public enum WelcomeAction: Equatable {
  case newAccountTapped
  case restoreTapped
  case finished
  case failed(String)
}

public struct WelcomeEnvironment {
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

extension WelcomeEnvironment {
  public static let unimplemented = WelcomeEnvironment(
    messenger: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented
  )
}

public let welcomeReducer = Reducer<WelcomeState, WelcomeAction, WelcomeEnvironment>
{ state, action, env in
  switch action {
  case .newAccountTapped:
    state.isCreatingAccount = true
    state.failure = nil
    return .future { fulfill in
      do {
        try env.messenger.create()
        fulfill(.success(.finished))
      }
      catch {
        fulfill(.success(.failed(error.localizedDescription)))
      }
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .restoreTapped:
    return .none

  case .finished:
    state.isCreatingAccount = false
    state.failure = nil
    return .none

  case .failed(let failure):
    state.isCreatingAccount = false
    state.failure = failure
    return .none
  }
}
