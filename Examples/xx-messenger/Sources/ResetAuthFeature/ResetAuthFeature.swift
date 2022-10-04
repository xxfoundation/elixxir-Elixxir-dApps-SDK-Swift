import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient

public struct ResetAuthState: Equatable {
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

public enum ResetAuthAction: Equatable {
  case resetTapped
  case didReset
  case didFail(String)
}

public struct ResetAuthEnvironment {
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

#if DEBUG
extension ResetAuthEnvironment {
  public static let unimplemented = ResetAuthEnvironment(
    messenger: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented
  )
}
#endif

public let resetAuthReducer = Reducer<ResetAuthState, ResetAuthAction, ResetAuthEnvironment>
{ state, action, env in
  switch action {
  case .resetTapped:
    state.isResetting = true
    state.didReset = false
    state.failure = nil
    return Effect.result { [state] in
      do {
        let e2e = try env.messenger.e2e.tryGet()
        _ = try e2e.resetAuthenticatedChannel(partner: state.partner)
        return .success(.didReset)
      } catch {
        return .success(.didFail(error.localizedDescription))
      }
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
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
