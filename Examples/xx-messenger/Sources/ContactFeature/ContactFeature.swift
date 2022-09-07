import AppCore
import ComposableArchitecture
import ComposablePresentation
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct ContactState: Equatable {
  public init(
    id: Data,
    dbContact: XXModels.Contact? = nil,
    xxContact: XXClient.Contact? = nil,
    sendRequest: ContactSendRequestState? = nil
  ) {
    self.id = id
    self.dbContact = dbContact
    self.xxContact = xxContact
    self.sendRequest = sendRequest
  }

  public var id: Data
  public var dbContact: XXModels.Contact?
  public var xxContact: XXClient.Contact?
  public var sendRequest: ContactSendRequestState?
}

public enum ContactAction: Equatable {
  case start
  case dbContactFetched(XXModels.Contact?)
  case saveFactsTapped
  case sendRequestTapped
  case sendRequestDismissed
  case sendRequest(ContactSendRequestAction)
}

public struct ContactEnvironment {
  public init(
    messenger: Messenger,
    db: DBManagerGetDB,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>,
    sendRequest: @escaping () -> ContactSendRequestEnvironment
  ) {
    self.messenger = messenger
    self.db = db
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
    self.sendRequest = sendRequest
  }

  public var messenger: Messenger
  public var db: DBManagerGetDB
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
  public var sendRequest: () -> ContactSendRequestEnvironment
}

#if DEBUG
extension ContactEnvironment {
  public static let unimplemented = ContactEnvironment(
    messenger: .unimplemented,
    db: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented,
    sendRequest: { .unimplemented }
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

  case .saveFactsTapped:
    guard let xxContact = state.xxContact else { return .none }
    return .fireAndForget { [state] in
      var dbContact = state.dbContact ?? XXModels.Contact(id: state.id)
      dbContact.marshaled = xxContact.data
      dbContact.username = xxContact.username
      dbContact.email = xxContact.email
      dbContact.phone = xxContact.phone
      _ = try! env.db().saveContact(dbContact)
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .sendRequestTapped:
    state.sendRequest = ContactSendRequestState()
    return .none

  case .sendRequestDismissed:
    state.sendRequest = nil
    return .none

  case .sendRequest(_):
    return .none
  }
}
.presenting(
  contactSendRequestReducer,
  state: .keyPath(\.sendRequest),
  id: .notNil(),
  action: /ContactAction.sendRequest,
  environment: { $0.sendRequest() }
)
