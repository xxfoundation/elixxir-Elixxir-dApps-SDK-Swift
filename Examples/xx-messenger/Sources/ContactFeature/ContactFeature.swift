import ComposableArchitecture
import XCTestDynamicOverlay

public struct ContactState: Equatable {
  public init() {}
}

public enum ContactAction: Equatable {
  case start
}

public struct ContactEnvironment {
  public init() {}
}

#if DEBUG
extension ContactEnvironment {
  public static let unimplemented = ContactEnvironment()
}
#endif

public let contactReducer = Reducer<ContactState, ContactAction, ContactEnvironment>
{ state, action, env in
  switch action {
  case .start:
    return .none
  }
}
