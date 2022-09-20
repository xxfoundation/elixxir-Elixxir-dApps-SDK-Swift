import AppCore
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
    phone: String = ""
  ) {
    self.contact = contact
    self.focusedField = focusedField
    self.email = email
    self.phone = phone
  }

  public var contact: XXModels.Contact?
  @BindableState public var focusedField: Field?
  @BindableState public var email: String
  @BindableState public var phone: String
}

public enum MyContactAction: Equatable, BindableAction {
  case start
  case contactFetched(XXModels.Contact?)
  case registerEmailTapped
  case unregisterEmailTapped
  case registerPhoneTapped
  case unregisterPhoneTapped
  case loadFactsTapped
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
    return .none

  case .binding(_):
    return .none
  }
}
.binding()
