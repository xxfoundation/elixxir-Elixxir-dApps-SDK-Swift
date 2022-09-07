import ComposableArchitecture
import XCTestDynamicOverlay

public struct ContactSendRequestState: Equatable {
  public init() {}
}

public enum ContactSendRequestAction: Equatable {
  case start
}

public struct ContactSendRequestEnvironment {
  public init() {}
}

#if DEBUG
extension ContactSendRequestEnvironment {
  public static let unimplemented = ContactSendRequestEnvironment()
}
#endif

public let contactSendRequestReducer = Reducer<ContactSendRequestState, ContactSendRequestAction, ContactSendRequestEnvironment>
{ state, action, env in
  switch action {
  case .start:
    return .none
  }
}
