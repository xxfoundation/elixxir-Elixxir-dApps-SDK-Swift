import AppCore
import Combine
import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct MyContactState: Equatable {
  public enum Field: String, Hashable {
    case email
    case phone
  }

  public init(
    contact: XXModels.Contact? = nil,
    focusedField: Field? = nil,
    email: String = "",
    phone: String = "",
    isLoadingFacts: Bool = false,
    alert: AlertState<MyContactAction>? = nil
  ) {
    self.contact = contact
    self.focusedField = focusedField
    self.email = email
    self.phone = phone
    self.isLoadingFacts = isLoadingFacts
    self.alert = alert
  }

  public var contact: XXModels.Contact?
  @BindableState public var focusedField: Field?
  @BindableState public var email: String
  @BindableState public var phone: String
  @BindableState public var isLoadingFacts: Bool
  public var alert: AlertState<MyContactAction>?
}

public enum MyContactAction: Equatable, BindableAction {
  case start
  case contactFetched(XXModels.Contact?)
  case registerEmailTapped
  case unregisterEmailTapped
  case registerPhoneTapped
  case unregisterPhoneTapped
  case loadFactsTapped
  case didFail(String)
  case alertDismissed
  case binding(BindingAction<MyContactState>)
}

public struct MyContactEnvironment {
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
extension MyContactEnvironment {
  public static let unimplemented = MyContactEnvironment(
    messenger: .unimplemented,
    db: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented
  )
}
#endif

public let myContactReducer = Reducer<MyContactState, MyContactAction, MyContactEnvironment>
{ state, action, env in
  enum DBFetchEffectID {}

  switch action {
  case .start:
    return Effect
      .catching { try env.messenger.e2e.tryGet().getContact().getId() }
      .tryMap { try env.db().fetchContactsPublisher(.init(id: [$0])) }
      .flatMap { $0 }
      .assertNoFailure()
      .map(\.first)
      .map(MyContactAction.contactFetched)
      .subscribe(on: env.bgQueue)
      .receive(on: env.mainQueue)
      .eraseToEffect()
      .cancellable(id: DBFetchEffectID.self, cancelInFlight: true)

  case .contactFetched(let contact):
    state.contact = contact
    return .none

  case .registerEmailTapped:
    return .none

  case .unregisterEmailTapped:
    return .none

  case .registerPhoneTapped:
    return .none

  case .unregisterPhoneTapped:
    return .none

  case .loadFactsTapped:
    state.isLoadingFacts = true
    return Effect.run { subscriber in
      do {
        let contactId = try env.messenger.e2e.tryGet().getContact().getId()
        if var dbContact = try env.db().fetchContacts(.init(id: [contactId])).first {
          let facts = try env.messenger.ud.tryGet().getFacts()
          dbContact.email = facts.get(.email)?.value
          dbContact.phone = facts.get(.phone)?.value
          try env.db().saveContact(dbContact)
        }
      } catch {
        subscriber.send(.didFail(error.localizedDescription))
      }
      subscriber.send(.set(\.$isLoadingFacts, false))
      subscriber.send(completion: .finished)
      return AnyCancellable {}
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .didFail(let failure):
    state.alert = .error(failure)
    return .none

  case .alertDismissed:
    state.alert = nil
    return .none

  case .binding(_):
    return .none
  }
}
.binding()
