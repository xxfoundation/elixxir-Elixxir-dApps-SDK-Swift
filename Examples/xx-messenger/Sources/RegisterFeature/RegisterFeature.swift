import AppCore
import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct RegisterState: Equatable {
  public enum Error: Swift.Error, Equatable {
    case usernameMismatch(registering: String, registered: String?)
  }

  public enum Field: String, Hashable {
    case username
  }

  public init(
    focusedField: Field? = nil,
    username: String = "",
    isRegistering: Bool = false,
    failure: String? = nil
  ) {
    self.focusedField = focusedField
    self.username = username
    self.isRegistering = isRegistering
    self.failure = failure
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
    db: DBManagerGetDB,
    now: @escaping () -> Date,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.messenger = messenger
    self.db = db
    self.now = now
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
  }

  public var messenger: Messenger
  public var db: DBManagerGetDB
  public var now: () -> Date
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
}

#if DEBUG
extension RegisterEnvironment {
  public static let unimplemented = RegisterEnvironment(
    messenger: .unimplemented,
    db: .unimplemented,
    now: XCTUnimplemented("\(Self.self).now"),
    mainQueue: .unimplemented,
    bgQueue: .unimplemented
  )
}
#endif

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
        let db = try env.db()
        try env.messenger.register(username: username)
        let contact = try env.messenger.myContact()
        let facts = try contact.getFacts()
        try db.saveContact(Contact(
          id: try contact.getId(),
          marshaled: contact.data,
          username: facts.get(.username)?.value,
          email: facts.get(.email)?.value,
          phone: facts.get(.phone)?.value,
          createdAt: env.now()
        ))
        guard facts.get(.username)?.value == username else {
          throw RegisterState.Error.usernameMismatch(
            registering: username,
            registered: facts.get(.username)?.value
          )
        }
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
    state.isRegistering = false
    return .none
  }
}
.binding()
