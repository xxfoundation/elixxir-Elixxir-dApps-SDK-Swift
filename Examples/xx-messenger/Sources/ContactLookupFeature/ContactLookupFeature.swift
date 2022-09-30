import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient

public struct ContactLookupState: Equatable {
  public init(
    id: Data,
    isLookingUp: Bool = false,
    failure: String? = nil
  ) {
    self.id = id
    self.isLookingUp = isLookingUp
    self.failure = failure
  }

  public var id: Data
  public var isLookingUp: Bool
  public var failure: String?
}

public enum ContactLookupAction: Equatable {
  case lookupTapped
  case didLookup(XXClient.Contact)
  case didFail(NSError)
}

public struct ContactLookupEnvironment {
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
extension ContactLookupEnvironment {
  public static let unimplemented = ContactLookupEnvironment(
    messenger: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented
  )
}
#endif

public let contactLookupReducer = Reducer<ContactLookupState, ContactLookupAction, ContactLookupEnvironment>
{ state, action, env in
  switch action {
  case .lookupTapped:
    state.isLookingUp = true
    return Effect.result { [state] in
      do {
        let contact = try env.messenger.lookupContact(id: state.id)
        return .success(.didLookup(contact))
      } catch {
        return .success(.didFail(error as NSError))
      }
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .didLookup(_):
    state.isLookingUp = false
    return .none

  case .didFail(let error):
    state.failure = error.localizedDescription
    state.isLookingUp = false
    return .none
  }
}
