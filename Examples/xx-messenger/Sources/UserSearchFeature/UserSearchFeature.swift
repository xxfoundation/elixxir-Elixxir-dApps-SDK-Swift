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

  public init(
    focusedField: Field? = nil,
    query: MessengerSearchUsers.Query = .init(),
    isSearching: Bool = false,
    failure: String? = nil,
    results: IdentifiedArrayOf<UserSearchResultState> = [],
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
  public var results: IdentifiedArrayOf<UserSearchResultState>
  public var contact: ContactState?
}

public enum UserSearchAction: Equatable, BindableAction {
  case searchTapped
  case didFail(String)
  case didSucceed([Contact])
  case didDismissContact
  case binding(BindingAction<UserSearchState>)
  case result(id: UserSearchResultState.ID, action: UserSearchResultAction)
  case contact(ContactAction)
}

public struct UserSearchEnvironment {
  public init(
    messenger: Messenger,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>,
    result: @escaping () -> UserSearchResultEnvironment,
    contact: @escaping () -> ContactEnvironment
  ) {
    self.messenger = messenger
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
    self.result = result
    self.contact = contact
  }

  public var messenger: Messenger
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
  public var result: () -> UserSearchResultEnvironment
  public var contact: () -> ContactEnvironment
}

#if DEBUG
extension UserSearchEnvironment {
  public static let unimplemented = UserSearchEnvironment(
    messenger: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented,
    result: { .unimplemented },
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
      return UserSearchResultState(id: id, xxContact: contact)
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

  case .result(let id, action: .tapped):
    state.contact = ContactState(
      id: id,
      xxContact: state.results[id: id]?.xxContact
    )
    return .none

  case .binding(_), .result(_, _), .contact(_):
    return .none
  }
}
.binding()
.presenting(
  forEach: userSearchResultReducer,
  state: \.results,
  action: /UserSearchAction.result(id:action:),
  environment: { $0.result() }
)
.presenting(
  contactReducer,
  state: .keyPath(\.contact),
  id: .keyPath(\.?.id),
  action: /UserSearchAction.contact,
  environment: { $0.contact() }
)
