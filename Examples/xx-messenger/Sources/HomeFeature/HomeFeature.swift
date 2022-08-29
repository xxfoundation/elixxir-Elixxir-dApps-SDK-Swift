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
    messenger: Messenger,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>
  ) {
    self.messenger = messenger
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
  }

  public var messenger: Messenger
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
}

extension HomeEnvironment {
  public static let unimplemented = HomeEnvironment(
    messenger: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented
  )
}

public let homeReducer = Reducer<HomeState, HomeAction, HomeEnvironment>
{ state, action, env in
  switch action {
  case .start:
    return .none
  }
}
