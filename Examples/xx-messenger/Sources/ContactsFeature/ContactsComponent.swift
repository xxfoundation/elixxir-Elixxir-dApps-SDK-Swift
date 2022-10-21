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

public struct ContactsComponent: ReducerProtocol {
  public struct State: Equatable {
    public init(
      myId: Data? = nil,
      contacts: IdentifiedArrayOf<XXModels.Contact> = [],
      contact: ContactComponent.State? = nil,
      myContact: MyContactComponent.State? = nil
    ) {
      self.myId = myId
      self.contacts = contacts
      self.contact = contact
      self.myContact = myContact
    }

    public var myId: Data?
    public var contacts: IdentifiedArrayOf<XXModels.Contact>
    public var contact: ContactComponent.State?
    public var myContact: MyContactComponent.State?
  }

  public enum Action: Equatable {
    case start
    case didFetchContacts([XXModels.Contact])
    case contactSelected(XXModels.Contact)
    case contactDismissed
    case contact(ContactComponent.Action)
    case myContactSelected
    case myContactDismissed
    case myContact(MyContactComponent.Action)
  }

  public init() {}

  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.dbManager.getDB) var db: DBManagerGetDB
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .start:
        state.myId = try? messenger.e2e.tryGet().getContact().getId()
        return Effect
          .catching { try db() }
          .flatMap { $0.fetchContactsPublisher(.init()) }
          .assertNoFailure()
          .map(Action.didFetchContacts)
          .subscribe(on: bgQueue)
          .receive(on: mainQueue)
          .eraseToEffect()

      case .didFetchContacts(var contacts):
        if let myId = state.myId,
           let myIndex = contacts.firstIndex(where: { $0.id == myId }) {
          contacts.move(fromOffsets: [myIndex], toOffset: contacts.startIndex)
        }
        state.contacts = IdentifiedArray(uniqueElements: contacts)
        return .none

      case .contactSelected(let contact):
        state.contact = ContactComponent.State(id: contact.id, dbContact: contact)
        return .none

      case .contactDismissed:
        state.contact = nil
        return .none

      case .myContactSelected:
        state.myContact = MyContactComponent.State()
        return .none

      case .myContactDismissed:
        state.myContact = nil
        return .none

      case .contact(_), .myContact(_):
        return .none
      }
    }
    .presenting(
      state: .keyPath(\.contact),
      id: .keyPath(\.?.id),
      action: /Action.contact,
      presented: { ContactComponent() }
    )
    .presenting(
      state: .keyPath(\.myContact),
      id: .notNil(),
      action: /Action.myContact,
      presented: { MyContactComponent() }
    )
  }
}
