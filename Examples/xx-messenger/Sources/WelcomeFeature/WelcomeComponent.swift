import ComposableArchitecture
import SwiftUI
import XXMessengerClient

public struct WelcomeComponent: ReducerProtocol {
  public struct State: Equatable {
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

  public enum Action: Equatable {
    case newAccountTapped
    case restoreTapped
    case finished
    case failed(String)
  }

  public init() {}

  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .newAccountTapped:
      state.isCreatingAccount = true
      state.failure = nil
      return .future { fulfill in
        do {
          try messenger.create()
          fulfill(.success(.finished))
        }
        catch {
          fulfill(.success(.failed(error.localizedDescription)))
        }
      }
      .subscribe(on: bgQueue)
      .receive(on: mainQueue)
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
}
