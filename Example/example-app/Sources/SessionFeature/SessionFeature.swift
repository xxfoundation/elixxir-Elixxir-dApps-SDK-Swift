import Combine
import ComposableArchitecture
import ElixxirDAppsSDK
import ErrorFeature

public struct SessionState: Equatable {
  public init(
    id: UUID,
    networkFollowerStatus: NetworkFollowerStatus? = nil,
    error: ErrorState? = nil
  ) {
    self.id = id
    self.networkFollowerStatus = networkFollowerStatus
    self.error = error
  }

  public var id: UUID
  public var networkFollowerStatus: NetworkFollowerStatus?
  public var error: ErrorState?
}

public enum SessionAction: Equatable {
  case viewDidLoad
  case updateNetworkFollowerStatus
  case didUpdateNetworkFollowerStatus(NetworkFollowerStatus?)
  case runNetworkFollower(Bool)
  case networkFollowerDidFail(NSError)
  case error(ErrorAction)
  case didDismissError
}

public struct SessionEnvironment {
  public init(
    getClient: @escaping () -> Client?,
    bgScheduler: AnySchedulerOf<DispatchQueue>,
    mainScheduler: AnySchedulerOf<DispatchQueue>
  ) {
    self.getClient = getClient
    self.bgScheduler = bgScheduler
    self.mainScheduler = mainScheduler
  }

  public var getClient: () -> Client?
  public var bgScheduler: AnySchedulerOf<DispatchQueue>
  public var mainScheduler: AnySchedulerOf<DispatchQueue>
}

public let sessionReducer = Reducer<SessionState, SessionAction, SessionEnvironment>
{ state, action, env in
  switch action {
  case .viewDidLoad:
    return .merge([
      .init(value: .updateNetworkFollowerStatus),
    ])

  case .updateNetworkFollowerStatus:
    return Effect.future { fulfill in
      let status = env.getClient()?.networkFollower.status()
      fulfill(.success(.didUpdateNetworkFollowerStatus(status)))
    }
    .subscribe(on: env.bgScheduler)
    .receive(on: env.mainScheduler)
    .eraseToEffect()

  case .didUpdateNetworkFollowerStatus(let status):
    state.networkFollowerStatus = status
    return .none

  case .runNetworkFollower(let start):
    state.networkFollowerStatus = start ? .starting : .stopping
    return Effect.run { subscriber in
      do {
        if start {
          try env.getClient()?.networkFollower.start(timeoutMS: 30_000)
        } else {
          try env.getClient()?.networkFollower.stop()
        }
      } catch {
        subscriber.send(.networkFollowerDidFail(error as NSError))
      }
      let status = env.getClient()?.networkFollower.status()
      subscriber.send(.didUpdateNetworkFollowerStatus(status))
      subscriber.send(completion: .finished)
      return AnyCancellable {}
    }
    .subscribe(on: env.bgScheduler)
    .receive(on: env.mainScheduler)
    .eraseToEffect()

  case .networkFollowerDidFail(let error):
    state.error = ErrorState(error: error)
    return .none

  case .didDismissError:
    state.error = nil
    return .none
  }
}

#if DEBUG
extension SessionEnvironment {
  public static let failing = SessionEnvironment(
    getClient: { .failing },
    bgScheduler: .failing,
    mainScheduler: .failing
  )
}
#endif
