import ComposableArchitecture

public struct SessionState: Equatable {
  public init() {}
}

public enum SessionAction: Equatable {
  case viewDidLoad
}

public struct SessionEnvironment {
  public init() {}
}

public let sessionReducer = Reducer<SessionState, SessionAction, SessionEnvironment>
{ state, action, env in
  switch action {
  case .viewDidLoad:
    return .none
  }
}

#if DEBUG
extension SessionEnvironment {
  public static let failing = SessionEnvironment()
}
#endif
