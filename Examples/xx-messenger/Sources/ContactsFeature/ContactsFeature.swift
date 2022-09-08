import ComposableArchitecture
import XCTestDynamicOverlay

public struct ContactsState: Equatable {
  public init() {}
}

public enum ContactsAction: Equatable {
  case start
}

public struct ContactsEnvironment {
  public init() {}
}

#if DEBUG
extension ContactsEnvironment {
  public static let unimplemented = ContactsEnvironment()
}
#endif

public let contactsReducer = Reducer<ContactsState, ContactsAction, ContactsEnvironment>
{ state, action, env in
  switch action {
  case .start:
    return .none
  }
}
