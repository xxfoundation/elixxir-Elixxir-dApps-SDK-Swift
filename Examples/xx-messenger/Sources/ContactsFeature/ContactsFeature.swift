import AppCore
import ComposableArchitecture
import ComposablePresentation
import ContactFeature
import Foundation
import XCTestDynamicOverlay
import XXModels

public struct ContactsState: Equatable {
  public init(
    contacts: IdentifiedArrayOf<Contact> = [],
    contact: ContactState? = nil
  ) {
    self.contacts = contacts
    self.contact = contact
  }

  public var contacts: IdentifiedArrayOf<XXModels.Contact>
  public var contact: ContactState?
}

public enum ContactsAction: Equatable {
  case start
  case didFetchContacts([XXModels.Contact])
  case contactSelected(XXModels.Contact)
  case contactDismissed
  case contact(ContactAction)
}

public struct ContactsEnvironment {
  public init(
    db: DBManagerGetDB,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>,
    contact: @escaping () -> ContactEnvironment
  ) {
    self.db = db
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
    self.contact = contact
  }

  public var db: DBManagerGetDB
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
  public var contact: () -> ContactEnvironment
}

#if DEBUG
extension ContactsEnvironment {
  public static let unimplemented = ContactsEnvironment(
    db: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented,
    contact: { .unimplemented }
  )
}
#endif

public let contactsReducer = Reducer<ContactsState, ContactsAction, ContactsEnvironment>
{ state, action, env in
  switch action {
  case .start:
    return Effect
      .catching { try env.db() }
      .flatMap { $0.fetchContactsPublisher(.init()) }
      .assertNoFailure()
      .map(ContactsAction.didFetchContacts)
      .subscribe(on: env.bgQueue)
      .receive(on: env.mainQueue)
      .eraseToEffect()

  case .didFetchContacts(let contacts):
    state.contacts = IdentifiedArray(uniqueElements: contacts)
    return .none

  case .contactSelected(let contact):
    state.contact = ContactState(id: contact.id, dbContact: contact)
    return .none

  case .contactDismissed:
    state.contact = nil
    return .none

  case .contact(_):
    return .none
  }
}
.presenting(
  contactReducer,
  state: .keyPath(\.contact),
  id: .keyPath(\.?.id),
  action: /ContactsAction.contact,
  environment: { $0.contact() }
)
