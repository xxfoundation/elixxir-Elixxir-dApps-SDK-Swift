import ComposableArchitecture
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
      contact: Contact,
      username: String? = nil,
      email: String? = nil,
      phone: String? = nil
    ) {
      self.id = id
      self.contact = contact
      self.username = username
      self.email = email
      self.phone = phone
    }

    public var id: Data
    public var contact: XXClient.Contact
    public var username: String?
    public var email: String?
    public var phone: String?
  }

  public init(
    focusedField: Field? = nil,
    query: MessengerSearchUsers.Query = .init(),
    isSearching: Bool = false,
    failure: String? = nil,
    results: IdentifiedArrayOf<Result> = []
  ) {
    self.focusedField = focusedField
    self.query = query
    self.isSearching = isSearching
    self.failure = failure
    self.results = results
  }

  @BindableState public var focusedField: Field?
  @BindableState public var query: MessengerSearchUsers.Query
  public var isSearching: Bool
  public var failure: String?
  public var results: IdentifiedArrayOf<Result>
}

public enum UserSearchAction: Equatable, BindableAction {
  case searchTapped
  case didFail(String)
  case didSucceed([Contact])
  case binding(BindingAction<UserSearchState>)
}

public struct UserSearchEnvironment {
  public init(
    messenger: Messenger,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.messenger = messenger
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
  }

  public var messenger: Messenger
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
}

#if DEBUG
extension UserSearchEnvironment {
  public static let unimplemented = UserSearchEnvironment(
    messenger: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented
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
      let facts = (try? contact.getFacts()) ?? []
      return UserSearchState.Result(
        id: id,
        contact: contact,
        username: facts.first(where: { $0.type == 0 })?.fact,
        email: facts.first(where: { $0.type == 1 })?.fact,
        phone: facts.first(where: { $0.type == 2 })?.fact
      )
    })
    return .none

  case .didFail(let failure):
    state.isSearching = false
    state.failure = failure
    state.results = []
    return .none

  case .binding(_):
    return .none
  }
}
.binding()
