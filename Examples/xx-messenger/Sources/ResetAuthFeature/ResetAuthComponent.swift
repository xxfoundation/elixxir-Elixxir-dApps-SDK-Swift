import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient

public struct ResetAuthComponent: ReducerProtocol {
  public struct State: Equatable {
    public init(
      partner: Contact,
      isResetting: Bool = false,
      failure: String? = nil,
      didReset: Bool = false
    ) {
      self.partner = partner
      self.isResetting = isResetting
      self.failure = failure
      self.didReset = didReset
    }

    public var partner: Contact
    public var isResetting: Bool
    public var failure: String?
    public var didReset: Bool
  }

  public enum Action: Equatable {
    case resetTapped
    case didReset
    case didFail(String)
  }

  public init() {}

  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  public func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
    switch action {
    case .resetTapped:
      state.isResetting = true
      state.didReset = false
      state.failure = nil
      return Effect.result { [state] in
        do {
          let e2e = try messenger.e2e.tryGet()
          _ = try e2e.resetAuthenticatedChannel(partner: state.partner)
          return .success(.didReset)
        } catch {
          return .success(.didFail(error.localizedDescription))
        }
      }
      .subscribe(on: bgQueue)
      .receive(on: mainQueue)
      .eraseToEffect()

    case .didReset:
      state.isResetting = false
      state.didReset = true
      state.failure = nil
      return .none

    case .didFail(let failure):
      state.isResetting = false
      state.didReset = false
      state.failure = failure
      return .none
    }
  }
}
