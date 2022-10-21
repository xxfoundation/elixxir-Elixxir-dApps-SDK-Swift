import AppCore
import ChatFeature
import CheckContactAuthFeature
import ComposableArchitecture
import ComposablePresentation
import ConfirmRequestFeature
import ContactLookupFeature
import Foundation
import ResetAuthFeature
import SendRequestFeature
import VerifyContactFeature
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient
import XXModels

public struct ContactComponent: ReducerProtocol {
  public struct State: Equatable {
    public init(
      id: Data,
      dbContact: XXModels.Contact? = nil,
      xxContact: XXClient.Contact? = nil,
      importUsername: Bool = true,
      importEmail: Bool = true,
      importPhone: Bool = true,
      lookup: ContactLookupComponent.State? = nil,
      sendRequest: SendRequestComponent.State? = nil,
      verifyContact: VerifyContactComponent.State? = nil,
      confirmRequest: ConfirmRequestComponent.State? = nil,
      checkAuth: CheckContactAuthComponent.State? = nil,
      resetAuth: ResetAuthComponent.State? = nil,
      chat: ChatComponent.State? = nil
    ) {
      self.id = id
      self.dbContact = dbContact
      self.xxContact = xxContact
      self.importUsername = importUsername
      self.importEmail = importEmail
      self.importPhone = importPhone
      self.lookup = lookup
      self.sendRequest = sendRequest
      self.verifyContact = verifyContact
      self.confirmRequest = confirmRequest
      self.checkAuth = checkAuth
      self.resetAuth = resetAuth
      self.chat = chat
    }

    public var id: Data
    public var dbContact: XXModels.Contact?
    public var xxContact: XXClient.Contact?
    @BindableState public var importUsername: Bool
    @BindableState public var importEmail: Bool
    @BindableState public var importPhone: Bool
    public var lookup: ContactLookupComponent.State?
    public var sendRequest: SendRequestComponent.State?
    public var verifyContact: VerifyContactComponent.State?
    public var confirmRequest: ConfirmRequestComponent.State?
    public var checkAuth: CheckContactAuthComponent.State?
    public var resetAuth: ResetAuthComponent.State?
    public var chat: ChatComponent.State?
  }

  public enum Action: Equatable, BindableAction {
    case start
    case dbContactFetched(XXModels.Contact?)
    case importFactsTapped
    case lookupTapped
    case lookupDismissed
    case lookup(ContactLookupComponent.Action)
    case sendRequestTapped
    case sendRequestDismissed
    case sendRequest(SendRequestComponent.Action)
    case verifyContactTapped
    case verifyContactDismissed
    case verifyContact(VerifyContactComponent.Action)
    case checkAuthTapped
    case checkAuthDismissed
    case checkAuth(CheckContactAuthComponent.Action)
    case confirmRequestTapped
    case confirmRequestDismissed
    case confirmRequest(ConfirmRequestComponent.Action)
    case resetAuthTapped
    case resetAuthDismissed
    case resetAuth(ResetAuthComponent.Action)
    case chatTapped
    case chatDismissed
    case chat(ChatComponent.Action)
    case binding(BindingAction<State>)
  }

  public init() {}

  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.dbManager.getDB) var db: DBManagerGetDB
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
      enum DBFetchEffectID {}

      switch action {
      case .start:
        return try! db().fetchContactsPublisher(.init(id: [state.id]))
          .assertNoFailure()
          .map(\.first)
          .map(Action.dbContactFetched)
          .subscribe(on: bgQueue)
          .receive(on: mainQueue)
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
          _ = try! db().saveContact(dbContact)
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .lookupTapped:
        state.lookup = ContactLookupComponent.State(id: state.id)
        return .none

      case .lookupDismissed:
        state.lookup = nil
        return .none

      case .lookup(.didLookup(let xxContact)):
        state.xxContact = xxContact
        state.lookup = nil
        return .none

      case .sendRequestTapped:
        if let xxContact = state.xxContact {
          state.sendRequest = SendRequestComponent.State(contact: xxContact)
        } else if let marshaled = state.dbContact?.marshaled {
          state.sendRequest = SendRequestComponent.State(contact: .live(marshaled))
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
          state.verifyContact = VerifyContactComponent.State(
            contact: .live(marshaled)
          )
        }
        return .none

      case .verifyContactDismissed:
        state.verifyContact = nil
        return .none

      case .checkAuthTapped:
        if let marshaled = state.dbContact?.marshaled {
          state.checkAuth = CheckContactAuthComponent.State(
            contact: .live(marshaled)
          )
        }
        return .none

      case .checkAuthDismissed:
        state.checkAuth = nil
        return .none

      case .confirmRequestTapped:
        if let marshaled = state.dbContact?.marshaled {
          state.confirmRequest = ConfirmRequestComponent.State(
            contact: .live(marshaled)
          )
        }
        return .none

      case .confirmRequestDismissed:
        state.confirmRequest = nil
        return .none

      case .chatTapped:
        state.chat = ChatComponent.State(id: .contact(state.id))
        return .none

      case .chatDismissed:
        state.chat = nil
        return .none

      case .resetAuthTapped:
        if let marshaled = state.dbContact?.marshaled {
          state.resetAuth = ResetAuthComponent.State(
            partner: .live(marshaled)
          )
        }
        return .none

      case .resetAuthDismissed:
        state.resetAuth = nil
        return .none

      case .binding(_), .lookup(_), .sendRequest(_),
          .verifyContact(_), .confirmRequest(_),
          .checkAuth(_), .resetAuth(_), .chat(_):
        return .none
      }
    }
    .presenting(
      state: .keyPath(\.lookup),
      id: .notNil(),
      action: /ContactComponent.Action.lookup,
      presented: { ContactLookupComponent() }
    )
    .presenting(
      state: .keyPath(\.sendRequest),
      id: .notNil(),
      action: /ContactComponent.Action.sendRequest,
      presented: { SendRequestComponent() }
    )
    .presenting(
      state: .keyPath(\.verifyContact),
      id: .notNil(),
      action: /ContactComponent.Action.verifyContact,
      presented: { VerifyContactComponent() }
    )
    .presenting(
      state: .keyPath(\.confirmRequest),
      id: .notNil(),
      action: /ContactComponent.Action.confirmRequest,
      presented: { ConfirmRequestComponent() }
    )
    .presenting(
      state: .keyPath(\.checkAuth),
      id: .notNil(),
      action: /ContactComponent.Action.checkAuth,
      presented: { CheckContactAuthComponent() }
    )
    .presenting(
      state: .keyPath(\.resetAuth),
      id: .notNil(),
      action: /ContactComponent.Action.resetAuth,
      presented: { ResetAuthComponent() }
    )
    .presenting(
      state: .keyPath(\.chat),
      id: .keyPath(\.?.id),
      action: /ContactComponent.Action.chat,
      presented: { ChatComponent() }
    )
  }
}
