import AppCore
import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXModels

public struct ContactsState: Equatable {
  public init(
    contacts: IdentifiedArrayOf<Contact> = []
  ) {
    self.contacts = contacts
  }

  public var contacts: IdentifiedArrayOf<XXModels.Contact>
}

public enum ContactsAction: Equatable {
  case start
  case didFetchContacts([XXModels.Contact])
}

public struct ContactsEnvironment {
  public init(
    db: DBManagerGetDB,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.db = db
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
  }

  public var db: DBManagerGetDB
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
}

#if DEBUG
extension ContactsEnvironment {
  public static let unimplemented = ContactsEnvironment(
    db: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented
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
  }
}
