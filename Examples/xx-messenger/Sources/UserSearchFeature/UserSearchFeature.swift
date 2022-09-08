import ComposableArchitecture
import ComposablePresentation
import ContactFeature
import Foundation
import XCTestDynamicOverlay
import XXClient
import XXMessengerClient

public struct UserSearchState: Equatable {
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
    query: MessengerSearchUsers.Query = .init(),
    isSearching: Bool = false,
    failure: String? = nil,
    results: IdentifiedArrayOf<Result> = [],
    contact: ContactState? = nil
  ) {
    self.focusedField = focusedField
    self.query = query
    self.isSearching = isSearching
    self.failure = failure
    self.results = results
    self.contact = contact
  }

  @BindableState public var focusedField: Field?
  @BindableState public var query: MessengerSearchUsers.Query
  public var isSearching: Bool
  public var failure: String?
  public var results: IdentifiedArrayOf<Result>
  public var contact: ContactState?
}

public enum UserSearchAction: Equatable, BindableAction {
  case searchTapped
  case didFail(String)
  case didSucceed([Contact])
  case didDismissContact
  case resultTapped(id: Data)
  case binding(BindingAction<UserSearchState>)
  case contact(ContactAction)
}

public struct UserSearchEnvironment {
  public init(
    messenger: Messenger,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>,
    contact: @escaping () -> ContactEnvironment
  ) {
    self.messenger = messenger
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
    self.contact = contact
  }

  public var messenger: Messenger
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
  public var contact: () -> ContactEnvironment
}

#if DEBUG
extension UserSearchEnvironment {
  public static let unimplemented = UserSearchEnvironment(
    messenger: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented,
    contact: { .unimplemented }
  )
}
#endif

public let userSearchReducer = Reducer<UserSearchState, UserSearchAction, UserSearchEnvironment>
{ state, action, env in
  switch action {
  case .searchTapped:
    state.focusedField = nil
    state.isSearching = true
    state.results = []
    state.failure = nil
    return .result { [query = state.query] in
      do {
        return .success(.didSucceed(try env.messenger.searchUsers(query: query)))
      } catch {
        return .success(.didFail(error.localizedDescription))
      }
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .didSucceed(let contacts):
    state.isSearching = false
    state.failure = nil
    state.results = IdentifiedArray(uniqueElements: contacts.compactMap { contact in
      guard let id = try? contact.getId() else { return nil }
      return UserSearchState.Result(
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
    state.contact = ContactState(
      id: id,
      xxContact: state.results[id: id]?.xxContact
    )
    return .none

  case .binding(_), .contact(_):
    return .none
  }
}
.binding()
.presenting(
  contactReducer,
  state: .keyPath(\.contact),
  id: .keyPath(\.?.id),
  action: /UserSearchAction.contact,
  environment: { $0.contact() }
)
