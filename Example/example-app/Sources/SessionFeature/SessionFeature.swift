import ComposableArchitecture
import ElixxirDAppsSDK

public struct SessionState: Equatable {
  public init(
    id: UUID
  ) {
    self.id = id
  }

  public var id: UUID
}

public enum SessionAction: Equatable {
  case viewDidLoad
}

public struct SessionEnvironment {
  public init(
    getClient: @escaping () -> Client?
  ) {
    self.getClient = getClient
  }

  public var getClient: () -> Client?
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
  public static let failing = SessionEnvironment(
    getClient: { .failing }
  )
}
#endif
