import AppCore
import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct ConfirmRequestState: Equatable {
  public enum Result: Equatable {
    case success
    case failure(String)
  }

  public init(
    contact: XXClient.Contact,
    isConfirming: Bool = false,
    result: Result? = nil
  ) {
    self.contact = contact
    self.isConfirming = isConfirming
    self.result = result
  }

  public var contact: XXClient.Contact
  public var isConfirming: Bool
  public var result: Result?
}

public enum ConfirmRequestAction: Equatable {
  case confirmTapped
  case didConfirm(ConfirmRequestState.Result)
}

public struct ConfirmRequestEnvironment {
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
extension ConfirmRequestEnvironment {
  public static let unimplemented = ConfirmRequestEnvironment(
    messenger: .unimplemented,
    db: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented
  )
}
#endif

public let confirmRequestReducer = Reducer<ConfirmRequestState, ConfirmRequestAction, ConfirmRequestEnvironment>
{ state, action, env in
  switch action {
  case .confirmTapped:
    state.isConfirming = true
    state.result = nil
    return Effect.result { [state] in
      func updateStatus(_ status: XXModels.Contact.AuthStatus) throws {
        try env.db().bulkUpdateContacts.callAsFunction(
          .init(id: [try state.contact.getId()]),
          .init(authStatus: status)
        )
      }
      do {
        try updateStatus(.confirming)
        let e2e = try env.messenger.e2e.tryGet()
        _ = try e2e.confirmReceivedRequest(partner: state.contact)
        try updateStatus(.friend)
        return .success(.didConfirm(.success))
      } catch {
        try? updateStatus(.confirmationFailed)
        return .success(.didConfirm(.failure(error.localizedDescription)))
      }
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .didConfirm(let result):
    state.isConfirming = false
    state.result = result
    return .none
  }
}
