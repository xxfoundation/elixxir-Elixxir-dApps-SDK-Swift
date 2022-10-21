import ComposableArchitecture
import ComposablePresentation
import ContactFeature
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient

public struct UserSearchComponent: ReducerProtocol {
  public struct State: Equatable {
    public enum Field: String, Hashable {
      case username
      case email
      case phone
    }

    public struct Result: Equatable, Identifiable {
      public init(
        id: Data,
        xxContact: XXClient.Contact,
        username: String? = nil,
        email: String? = nil,
        phone: String? = nil
      ) {
        self.id = id
        self.xxContact = xxContact
        self.username = username
        self.email = email
        self.phone = phone
      }

      public var id: Data
      public var xxContact: XXClient.Contact
      public var username: String?
      public var email: String?
      public var phone: String?

      public var hasFacts: Bool {
        username != nil || email != nil || phone != nil
      }
    }

    public init(
      focusedField: Field? = nil,
      query: MessengerSearchContacts.Query = .init(),
      isSearching: Bool = false,
      failure: String? = nil,
      results: IdentifiedArrayOf<Result> = [],
      contact: ContactComponent.State? = nil
    ) {
      self.focusedField = focusedField
      self.query = query
      self.isSearching = isSearching
      self.failure = failure
      self.results = results
      self.contact = contact
    }

    @BindableState public var focusedField: Field?
    @BindableState public var query: MessengerSearchContacts.Query
    public var isSearching: Bool
    public var failure: String?
    public var results: IdentifiedArrayOf<Result>
    public var contact: ContactComponent.State?
  }

  public enum Action: Equatable, BindableAction {
    case searchTapped
    case didFail(String)
    case didSucceed([Contact])
    case didDismissContact
    case resultTapped(id: Data)
    case binding(BindingAction<State>)
    case contact(ContactComponent.Action)
  }

  public init() {}

  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .searchTapped:
        state.focusedField = nil
        state.isSearching = true
        state.results = []
        state.failure = nil
        return .result { [query = state.query] in
          do {
            return .success(.didSucceed(try messenger.searchContacts(query: query)))
          } catch {
            return .success(.didFail(error.localizedDescription))
          }
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()

      case .didSucceed(let contacts):
        state.isSearching = false
        state.failure = nil
        state.results = IdentifiedArray(uniqueElements: contacts.compactMap { contact in
          guard let id = try? contact.getId() else { return nil }
          return State.Result(
            id: id,
            xxContact: contact,
            username: try? contact.getFact(.username)?.value,
            email: try? contact.getFact(.email)?.value,
            phone: try? contact.getFact(.phone)?.value
          )
        })
        return .none

      case .didFail(let failure):
        state.isSearching = false
        state.failure = failure
        state.results = []
        return .none

      case .didDismissContact:
        state.contact = nil
        return .none

      case .resultTapped(let id):
        state.contact = ContactComponent.State(
          id: id,
          xxContact: state.results[id: id]?.xxContact
        )
        return .none

      case .binding(_), .contact(_):
        return .none
      }
    }
    .presenting(
      state: .keyPath(\.contact),
      id: .keyPath(\.?.id),
      action: /Action.contact,
      presented: { ContactComponent() }
    )
  }
}
