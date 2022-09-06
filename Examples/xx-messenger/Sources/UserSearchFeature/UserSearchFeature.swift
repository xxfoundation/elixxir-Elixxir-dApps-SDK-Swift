import ComposableArchitecture
import XCTestDynamicOverlay

public struct UserSearchState: Equatable {
  public init() {}
}

public enum UserSearchAction: Equatable {}

public struct UserSearchEnvironment {
  public init() {}
}

#if DEBUG
extension UserSearchEnvironment {
  public static let unimplemented = UserSearchEnvironment()
}
#endif

public let userSearchReducer = Reducer<UserSearchState, UserSearchAction, UserSearchEnvironment>.empty
