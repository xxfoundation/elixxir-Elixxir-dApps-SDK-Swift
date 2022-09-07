import ComposableArchitecture
import XCTestDynamicOverlay

public struct SendRequestState: Equatable {
  public init() {}
}

public enum SendRequestAction: Equatable {
  case start
}

public struct SendRequestEnvironment {
  public init() {}
}

#if DEBUG
extension SendRequestEnvironment {
  public static let unimplemented = SendRequestEnvironment()
}
#endif

public let sendRequestReducer = Reducer<SendRequestState, SendRequestAction, SendRequestEnvironment>
{ state, action, env in
  switch action {
  case .start:
    return .none
  }
}
