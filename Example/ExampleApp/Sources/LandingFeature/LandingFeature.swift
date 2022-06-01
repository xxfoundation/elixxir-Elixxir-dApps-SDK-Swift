import ComposableArchitecture

public struct LandingState: Equatable {
  public init() {}
}

public enum LandingAction: Equatable {
  case viewDidLoad
}

public struct LandingEnvironment {
  public init() {}
}

public let landingReducer = Reducer<LandingState, LandingAction, LandingEnvironment>
{ state, action, env in
  switch action {
  case .viewDidLoad:
    return .none
  }
}

#if DEBUG
extension LandingEnvironment {
  public static let failing = LandingEnvironment()
}
#endif
