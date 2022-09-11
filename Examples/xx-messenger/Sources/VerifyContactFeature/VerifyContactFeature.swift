import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient

public struct VerifyContactState: Equatable {
  public enum Result: Equatable {
    case success(Bool)
    case failure(String)
  }

  public init(
    contact: Contact,
    isVerifying: Bool = false,
    result: Result? = nil
  ) {
    self.contact = contact
    self.isVerifying = isVerifying
    self.result = result
  }

  public var contact: Contact
  public var isVerifying: Bool
  public var result: Result?
}

public enum VerifyContactAction: Equatable {
  case verifyTapped
  case didVerify(VerifyContactState.Result)
}

public struct VerifyContactEnvironment {
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
extension VerifyContactEnvironment {
  public static let unimplemented = VerifyContactEnvironment(
    messenger: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented
  )
}
#endif

public let verifyContactReducer = Reducer<VerifyContactState, VerifyContactAction, VerifyContactEnvironment>
{ state, action, env in
  switch action {
  case .verifyTapped:
    state.isVerifying = true
    state.result = nil
    return Effect.result { [state] in
      do {
        let result = try env.messenger.verifyContact(state.contact)
        return .success(.didVerify(.success(result)))
      } catch {
        return .success(.didVerify(.failure(error.localizedDescription)))
      }
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .didVerify(let result):
    state.isVerifying = false
    state.result = result
    return .none
  }
}
