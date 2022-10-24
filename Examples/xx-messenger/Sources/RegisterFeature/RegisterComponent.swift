import AppCore
import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct RegisterComponent: ReducerProtocol {
  public struct State: Equatable {
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

  public enum Action: Equatable, BindableAction {
    case registerTapped
    case failed(String)
    case finished
    case binding(BindingAction<State>)
  }

  public init() {}

  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.dbManager.getDB) var db: DBManagerGetDB
  @Dependency(\.app.now) var now: () -> Date
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding(_):
        return .none

      case .registerTapped:
        state.focusedField = nil
        state.isRegistering = true
        state.failure = nil
        return .future { [username = state.username] fulfill in
          do {
            let db = try db()
            try messenger.register(username: username)
            let contact = try messenger.myContact()
            let facts = try contact.getFacts()
            try db.saveContact(Contact(
              id: try contact.getId(),
              marshaled: contact.data,
              username: facts.get(.username)?.value,
              email: facts.get(.email)?.value,
              phone: facts.get(.phone)?.value,
              createdAt: now()
            ))
            guard facts.get(.username)?.value == username else {
              throw State.Error.usernameMismatch(
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
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
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
  }
}
