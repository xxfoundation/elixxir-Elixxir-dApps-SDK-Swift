import ComposableArchitecture
import Foundation
import XCTestDynamicOverlay
import XXClient

public struct UserSearchResultState: Equatable, Identifiable {
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
}

public enum UserSearchResultAction: Equatable {
  case start
  case tapped
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
    state.username = state.xxContact.username
    state.email = state.xxContact.email
    state.phone = state.xxContact.phone
    return .none

  case .tapped:
    return .none
  }
}
