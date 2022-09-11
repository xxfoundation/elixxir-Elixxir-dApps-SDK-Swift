import AppCore
import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct VerifyContactState: Equatable {
  public enum Result: Equatable {
    case success(Bool)
    case failure(String)
  }

  public init(
    contact: XXClient.Contact,
    isVerifying: Bool = false,
    result: Result? = nil
  ) {
    self.contact = contact
    self.isVerifying = isVerifying
    self.result = result
  }

  public var contact: XXClient.Contact
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
    db: DBManagerGetDB,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.messenger = messenger
    self.db = db
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
  }

  public var messenger: Messenger
  public var db: DBManagerGetDB
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
}

#if DEBUG
extension VerifyContactEnvironment {
  public static let unimplemented = VerifyContactEnvironment(
    messenger: .unimplemented,
    db: .unimplemented,
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
        let contactId = try state.contact.getId()
        try env.db().bulkUpdateContacts.callAsFunction(
          .init(id: [contactId]),
          .init(authStatus: result ? .verified : .verificationFailed)
        )
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
