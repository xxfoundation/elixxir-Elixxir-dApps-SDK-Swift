import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient

public struct UserSearchResultState: Equatable, Identifiable {
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

public enum UserSearchResultAction: Equatable {
  case start
}

public struct UserSearchResultEnvironment {
  public init() {}
}

#if DEBUG
extension UserSearchResultEnvironment {
  public static let unimplemented = UserSearchResultEnvironment()
}
#endif

public let userSearchResultReducer = Reducer<UserSearchResultState, UserSearchResultAction, UserSearchResultEnvironment>
{ state, action, env in
  switch action {
  case .start:
    let facts = (try? state.contact.getFacts()) ?? []
    state.username = facts.first(where: { $0.type == 0 })?.fact
    state.email = facts.first(where: { $0.type == 1 })?.fact
    state.phone = facts.first(where: { $0.type == 2 })?.fact
    return .none
  }
}
