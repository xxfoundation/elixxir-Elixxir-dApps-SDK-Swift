import AppCore
import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct CheckContactAuthState: Equatable {
  public enum Result: Equatable {
    case success(Bool)
    case failure(String)
  }

  public init(
    contact: XXClient.Contact,
    isChecking: Bool = false,
    result: Result? = nil
  ) {
    self.contact = contact
    self.isChecking = isChecking
    self.result = result
  }

  public var contact: XXClient.Contact
  public var isChecking: Bool
  public var result: Result?
}

public enum CheckContactAuthAction: Equatable {
  case checkTapped
  case didCheck(CheckContactAuthState.Result)
}

public struct CheckContactAuthEnvironment {
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
extension CheckContactAuthEnvironment {
  public static let unimplemented = CheckContactAuthEnvironment(
    messenger: .unimplemented,
    db: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented
  )
}
#endif

public let checkContactAuthReducer = Reducer<CheckContactAuthState, CheckContactAuthAction, CheckContactAuthEnvironment>
{ state, action, env in
  switch action {
  case .checkTapped:
    state.isChecking = true
    state.result = nil
    return Effect.result { [state] in
      do {
        let e2e = try env.messenger.e2e.tryGet()
        let contactId = try state.contact.getId()
        let result = try e2e.hasAuthenticatedChannel(partnerId: contactId)
        try env.db().bulkUpdateContacts.callAsFunction(
          .init(id: [contactId]),
          .init(authStatus: result ? .friend : .stranger)
        )
        return .success(.didCheck(.success(result)))
      } catch {
        return .success(.didCheck(.failure(error.localizedDescription)))
      }
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .didCheck(let result):
    state.isChecking = false
    state.result = result
    return .none
  }
}
