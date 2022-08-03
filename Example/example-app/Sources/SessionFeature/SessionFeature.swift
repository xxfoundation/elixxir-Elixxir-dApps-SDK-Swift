import Combine
import ComposableArchitecture
import ElixxirDAppsSDK
import ErrorFeature
import XCTestDynamicOverlay

public struct SessionState: Equatable {
  public init(
    id: UUID,
    networkFollowerStatus: NetworkFollowerStatus? = nil,
    isNetworkHealthy: Bool? = nil,
    error: ErrorState? = nil
  ) {
    self.id = id
    self.networkFollowerStatus = networkFollowerStatus
    self.isNetworkHealthy = isNetworkHealthy
    self.error = error
  }

  public var id: UUID
  public var networkFollowerStatus: NetworkFollowerStatus?
  public var isNetworkHealthy: Bool?
  public var error: ErrorState?
}

public enum SessionAction: Equatable {
  case viewDidLoad
  case updateNetworkFollowerStatus
  case didUpdateNetworkFollowerStatus(NetworkFollowerStatus?)
  case runNetworkFollower(Bool)
  case networkFollowerDidFail(NSError)
  case monitorNetworkHealth(Bool)
  case didUpdateNetworkHealth(Bool?)
  case didDismissError
  case error(ErrorAction)
}

public struct SessionEnvironment {
  public init(
    getCMix: @escaping () -> CMix?,
    bgScheduler: AnySchedulerOf<DispatchQueue>,
    mainScheduler: AnySchedulerOf<DispatchQueue>,
    error: ErrorEnvironment
  ) {
    self.getCMix = getCMix
    self.bgScheduler = bgScheduler
    self.mainScheduler = mainScheduler
    self.error = error
  }

  public var getCMix: () -> CMix?
  public var bgScheduler: AnySchedulerOf<DispatchQueue>
  public var mainScheduler: AnySchedulerOf<DispatchQueue>
  public var error: ErrorEnvironment
}

public let sessionReducer = Reducer<SessionState, SessionAction, SessionEnvironment>
{ state, action, env in
  switch action {
  case .viewDidLoad:
    return .merge([
      .init(value: .updateNetworkFollowerStatus),
      .init(value: .monitorNetworkHealth(true)),
    ])

  case .updateNetworkFollowerStatus:
    return Effect.future { fulfill in
      let status = env.getCMix()?.networkFollowerStatus()
      fulfill(.success(.didUpdateNetworkFollowerStatus(status)))
    }
    .subscribe(on: env.bgScheduler)
    .receive(on: env.mainScheduler)
    .eraseToEffect()

  case .didUpdateNetworkFollowerStatus(let status):
    state.networkFollowerStatus = status
    return .none

  case .runNetworkFollower(let start):
    return Effect.run { subscriber in
      do {
        if start {
          try env.getCMix()?.startNetworkFollower(timeoutMS: 30_000)
        } else {
          try env.getCMix()?.stopNetworkFollower()
        }
      } catch {
        subscriber.send(.networkFollowerDidFail(error as NSError))
      }
      let status = env.getCMix()?.networkFollowerStatus()
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

  case .monitorNetworkHealth(let start):
    struct MonitorEffectId: Hashable {
      var id: UUID
    }
    let effectId = MonitorEffectId(id: state.id)
    if start {
      return Effect.run { subscriber in
        let callback = HealthCallback { isHealthy in
          subscriber.send(.didUpdateNetworkHealth(isHealthy))
        }
        let cancellable = env.getCMix()?.addHealthCallback(callback)
        return AnyCancellable {
          cancellable?.cancel()
        }
      }
      .subscribe(on: env.bgScheduler)
      .receive(on: env.mainScheduler)
      .eraseToEffect()
      .cancellable(id: effectId, cancelInFlight: true)
    } else {
      return Effect.cancel(id: effectId)
        .subscribe(on: env.bgScheduler)
        .eraseToEffect()
    }

  case .didUpdateNetworkHealth(let isHealthy):
    state.isNetworkHealthy = isHealthy
    return .none

  case .didDismissError:
    state.error = nil
    return .none

  case .error(_):
    return .none
  }
}
.presenting(
  errorReducer,
  state: .keyPath(\.error),
  id: .keyPath(\.?.error),
  action: /SessionAction.error,
  environment: \.error
)

extension SessionEnvironment {
  public static let unimplemented = SessionEnvironment(
    getCMix: XCTUnimplemented("\(Self.self).getCMix"),
    bgScheduler: .unimplemented,
    mainScheduler: .unimplemented,
    error: .unimplemented
  )
}
