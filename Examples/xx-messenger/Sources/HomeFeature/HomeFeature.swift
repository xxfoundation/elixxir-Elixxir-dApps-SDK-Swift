import ComposableArchitecture
import XXClient
import XXMessengerClient

public struct HomeState: Equatable {
  public init() {}
}

public enum HomeAction: Equatable {
  case start
}

public struct HomeEnvironment {
  public init(
    messenger: Messenger
  ) {
    self.messenger = messenger
  }

  public var messenger: Messenger
}

extension HomeEnvironment {
  public static let unimplemented = HomeEnvironment(
    messenger: .unimplemented
  )
}

public let homeReducer = Reducer<HomeState, HomeAction, HomeEnvironment>
{ state, action, env in
  switch action {
  case .start:
    return .none
  }
}
