import AppCore
import ComposableArchitecture
import ComposablePresentation
import ContactFeature
import Foundation
import MyContactFeature
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct ContactsState: Equatable {
  public init(
    myId: Data? = nil,
    contacts: IdentifiedArrayOf<XXModels.Contact> = [],
    contact: ContactState? = nil,
    myContact: MyContactState? = nil
  ) {
    self.myId = myId
    self.contacts = contacts
    self.contact = contact
    self.myContact = myContact
  }

  public var myId: Data?
  public var contacts: IdentifiedArrayOf<XXModels.Contact>
  public var contact: ContactState?
  public var myContact: MyContactState?
}

public enum ContactsAction: Equatable {
  case start
  case didFetchContacts([XXModels.Contact])
  case contactSelected(XXModels.Contact)
  case contactDismissed
  case contact(ContactAction)
  case myContactSelected
  case myContactDismissed
  case myContact(MyContactAction)
}

public struct ContactsEnvironment {
  public init(
    messenger: Messenger,
    db: DBManagerGetDB,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>,
    contact: @escaping () -> ContactEnvironment,
    myContact: @escaping () -> MyContactEnvironment
  ) {
    self.messenger = messenger
    self.db = db
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
    self.contact = contact
    self.myContact = myContact
  }

  public var messenger: Messenger
  public var db: DBManagerGetDB
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
  public var contact: () -> ContactEnvironment
  public var myContact: () -> MyContactEnvironment
}

#if DEBUG
extension ContactsEnvironment {
  public static let unimplemented = ContactsEnvironment(
    messenger: .unimplemented,
    db: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented,
    contact: { .unimplemented },
    myContact: { .unimplemented }
  )
}
#endif

public let contactsReducer = Reducer<ContactsState, ContactsAction, ContactsEnvironment>
{ state, action, env in
  switch action {
  case .start:
    state.myId = try? env.messenger.e2e.tryGet().getContact().getId()
    return Effect
      .catching { try env.db() }
      .flatMap { $0.fetchContactsPublisher(.init()) }
      .assertNoFailure()
      .map(ContactsAction.didFetchContacts)
      .subscribe(on: env.bgQueue)
      .receive(on: env.mainQueue)
      .eraseToEffect()

  case .didFetchContacts(var contacts):
    if let myId = state.myId,
       let myIndex = contacts.firstIndex(where: { $0.id == myId }) {
      contacts.move(fromOffsets: [myIndex], toOffset: contacts.startIndex)
    }
    state.contacts = IdentifiedArray(uniqueElements: contacts)
    return .none

  case .contactSelected(let contact):
    state.contact = ContactState(id: contact.id, dbContact: contact)
    return .none

  case .contactDismissed:
    state.contact = nil
    return .none

  case .myContactSelected:
    state.myContact = MyContactState()
    return .none

  case .myContactDismissed:
    state.myContact = nil
    return .none

  case .contact(_), .myContact(_):
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
.presenting(
  myContactReducer,
  state: .keyPath(\.myContact),
  id: .notNil(),
  action: /ContactsAction.myContact,
  environment: { $0.myContact() }
)
