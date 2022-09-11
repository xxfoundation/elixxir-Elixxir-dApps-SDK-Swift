import AppCore
import CheckContactAuthFeature
import ComposableArchitecture
import ComposablePresentation
import ConfirmRequestFeature
import Foundation
import SendRequestFeature
import VerifyContactFeature
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct ContactState: Equatable {
  public init(
    id: Data,
    dbContact: XXModels.Contact? = nil,
    xxContact: XXClient.Contact? = nil,
    importUsername: Bool = true,
    importEmail: Bool = true,
    importPhone: Bool = true,
    sendRequest: SendRequestState? = nil,
    verifyContact: VerifyContactState? = nil,
    confirmRequest: ConfirmRequestState? = nil,
    checkAuth: CheckContactAuthState? = nil
  ) {
    self.id = id
    self.dbContact = dbContact
    self.xxContact = xxContact
    self.importUsername = importUsername
    self.importEmail = importEmail
    self.importPhone = importPhone
    self.sendRequest = sendRequest
    self.verifyContact = verifyContact
    self.confirmRequest = confirmRequest
    self.checkAuth = checkAuth
  }

  public var id: Data
  public var dbContact: XXModels.Contact?
  public var xxContact: XXClient.Contact?
  @BindableState public var importUsername: Bool
  @BindableState public var importEmail: Bool
  @BindableState public var importPhone: Bool
  public var sendRequest: SendRequestState?
  public var verifyContact: VerifyContactState?
  public var confirmRequest: ConfirmRequestState?
  public var checkAuth: CheckContactAuthState?
}

public enum ContactAction: Equatable, BindableAction {
  case start
  case dbContactFetched(XXModels.Contact?)
  case importFactsTapped
  case sendRequestTapped
  case sendRequestDismissed
  case sendRequest(SendRequestAction)
  case verifyContactTapped
  case verifyContactDismissed
  case verifyContact(VerifyContactAction)
  case checkAuthTapped
  case checkAuthDismissed
  case checkAuth(CheckContactAuthAction)
  case confirmRequestTapped
  case confirmRequestDismissed
  case confirmRequest(ConfirmRequestAction)
  case binding(BindingAction<ContactState>)
}

public struct ContactEnvironment {
  public init(
    messenger: Messenger,
    db: DBManagerGetDB,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>,
    sendRequest: @escaping () -> SendRequestEnvironment,
    verifyContact: @escaping () -> VerifyContactEnvironment,
    confirmRequest: @escaping () -> ConfirmRequestEnvironment,
    checkAuth: @escaping () -> CheckContactAuthEnvironment
  ) {
    self.messenger = messenger
    self.db = db
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
    self.sendRequest = sendRequest
    self.verifyContact = verifyContact
    self.confirmRequest = confirmRequest
    self.checkAuth = checkAuth
  }

  public var messenger: Messenger
  public var db: DBManagerGetDB
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
  public var sendRequest: () -> SendRequestEnvironment
  public var verifyContact: () -> VerifyContactEnvironment
  public var confirmRequest: () -> ConfirmRequestEnvironment
  public var checkAuth: () -> CheckContactAuthEnvironment
}

#if DEBUG
extension ContactEnvironment {
  public static let unimplemented = ContactEnvironment(
    messenger: .unimplemented,
    db: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented,
    sendRequest: { .unimplemented },
    verifyContact: { .unimplemented },
    confirmRequest: { .unimplemented },
    checkAuth: { .unimplemented }
  )
}
#endif

public let contactReducer = Reducer<ContactState, ContactAction, ContactEnvironment>
{ state, action, env in
  enum DBFetchEffectID {}

  switch action {
  case .start:
    return try! env.db().fetchContactsPublisher(.init(id: [state.id]))
      .assertNoFailure()
      .map(\.first)
      .map(ContactAction.dbContactFetched)
      .subscribe(on: env.bgQueue)
      .receive(on: env.mainQueue)
      .eraseToEffect()
      .cancellable(id: DBFetchEffectID.self, cancelInFlight: true)

  case .dbContactFetched(let contact):
    state.dbContact = contact
    return .none

  case .importFactsTapped:
    guard let xxContact = state.xxContact else { return .none }
    return .fireAndForget { [state] in
      var dbContact = state.dbContact ?? XXModels.Contact(id: state.id)
      dbContact.marshaled = xxContact.data
      if state.importUsername {
        dbContact.username = try? xxContact.getFact(.username)?.value
      }
      if state.importEmail {
        dbContact.email = try? xxContact.getFact(.email)?.value
      }
      if state.importPhone {
        dbContact.phone = try? xxContact.getFact(.phone)?.value
      }
      _ = try! env.db().saveContact(dbContact)
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .sendRequestTapped:
    if let xxContact = state.xxContact {
      state.sendRequest = SendRequestState(contact: xxContact)
    } else if let marshaled = state.dbContact?.marshaled {
      state.sendRequest = SendRequestState(contact: .live(marshaled))
    }
    return .none

  case .sendRequestDismissed:
    state.sendRequest = nil
    return .none

  case .sendRequest(.sendSucceeded):
    state.sendRequest = nil
    return .none

  case .verifyContactTapped:
    if let marshaled = state.dbContact?.marshaled {
      state.verifyContact = VerifyContactState(
        contact: .live(marshaled)
      )
    }
    return .none

  case .verifyContactDismissed:
    state.verifyContact = nil
    return .none

  case .checkAuthTapped:
    if let marshaled = state.dbContact?.marshaled {
      state.checkAuth = CheckContactAuthState(
        contact: .live(marshaled)
      )
    }
    return .none

  case .checkAuthDismissed:
    state.checkAuth = nil
    return .none

  case .confirmRequestTapped:
    if let marshaled = state.dbContact?.marshaled {
      state.confirmRequest = ConfirmRequestState(
        contact: .live(marshaled)
      )
    }
    return .none

  case .confirmRequestDismissed:
    state.confirmRequest = nil
    return .none

  case .binding(_), .sendRequest(_), .verifyContact(_), .confirmRequest(_), .checkAuth(_):
    return .none
  }
}
.binding()
.presenting(
  sendRequestReducer,
  state: .keyPath(\.sendRequest),
  id: .notNil(),
  action: /ContactAction.sendRequest,
  environment: { $0.sendRequest() }
)
.presenting(
  verifyContactReducer,
  state: .keyPath(\.verifyContact),
  id: .notNil(),
  action: /ContactAction.verifyContact,
  environment: { $0.verifyContact() }
)
.presenting(
  confirmRequestReducer,
  state: .keyPath(\.confirmRequest),
  id: .notNil(),
  action: /ContactAction.confirmRequest,
  environment: { $0.confirmRequest() }
)
.presenting(
  checkContactAuthReducer,
  state: .keyPath(\.checkAuth),
  id: .notNil(),
  action: /ContactAction.checkAuth,
  environment: { $0.checkAuth() }
)
