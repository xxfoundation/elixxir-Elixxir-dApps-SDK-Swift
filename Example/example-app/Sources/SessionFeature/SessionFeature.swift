import Combine
import ComposableArchitecture
import ElixxirDAppsSDK
import ErrorFeature
import MyContactFeature
import MyIdentityFeature

public struct SessionState: Equatable {
  public init(
    id: UUID,
    networkFollowerStatus: NetworkFollowerStatus? = nil,
    isNetworkHealthy: Bool? = nil,
    error: ErrorState? = nil,
    myIdentity: MyIdentityState? = nil,
    myContact: MyContactState? = nil
  ) {
    self.id = id
    self.networkFollowerStatus = networkFollowerStatus
    self.isNetworkHealthy = isNetworkHealthy
    self.error = error
    self.myIdentity = myIdentity
    self.myContact = myContact
  }

  public var id: UUID
  public var networkFollowerStatus: NetworkFollowerStatus?
  public var isNetworkHealthy: Bool?
  public var error: ErrorState?
  public var myIdentity: MyIdentityState?
  public var myContact: MyContactState?
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
  case presentMyIdentity
  case didDismissMyIdentity
  case presentMyContact
  case didDismissMyContact
  case error(ErrorAction)
  case myIdentity(MyIdentityAction)
  case myContact(MyContactAction)
}

public struct SessionEnvironment {
  public init(
    getClient: @escaping () -> Client?,
    bgScheduler: AnySchedulerOf<DispatchQueue>,
    mainScheduler: AnySchedulerOf<DispatchQueue>,
    makeId: @escaping () -> UUID,
    error: ErrorEnvironment,
    myIdentity: MyIdentityEnvironment,
    myContact: MyContactEnvironment
  ) {
    self.getClient = getClient
    self.bgScheduler = bgScheduler
    self.mainScheduler = mainScheduler
    self.makeId = makeId
    self.error = error
    self.myIdentity = myIdentity
    self.myContact = myContact
  }

  public var getClient: () -> Client?
  public var bgScheduler: AnySchedulerOf<DispatchQueue>
  public var mainScheduler: AnySchedulerOf<DispatchQueue>
  public var makeId: () -> UUID
  public var error: ErrorEnvironment
  public var myIdentity: MyIdentityEnvironment
  public var myContact: MyContactEnvironment
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

  case .monitorNetworkHealth(let start):
    struct MonitorEffectId: Hashable {
      var id: UUID
    }
    let effectId = MonitorEffectId(id: state.id)
    if start {
      return Effect.run { subscriber in
        var cancellable = env.getClient()?.monitorNetworkHealth { isHealthy in
          subscriber.send(.didUpdateNetworkHealth(isHealthy))
        }
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

  case .presentMyIdentity:
    if state.myIdentity == nil {
      state.myIdentity = MyIdentityState(id: env.makeId())
    }
    return .none

  case .didDismissMyIdentity:
    state.myIdentity = nil
    return .none

  case .presentMyContact:
    if state.myContact == nil {
      state.myContact = MyContactState(id: env.makeId())
    }
    return .none

  case .didDismissMyContact:
    state.myContact = nil
    return .none

  case .error(_), .myIdentity(_), .myContact(_):
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
.presenting(
  myIdentityReducer,
  state: .keyPath(\.myIdentity),
  id: .keyPath(\.?.id),
  action: /SessionAction.myIdentity,
  environment: \.myIdentity
)
.presenting(
  myContactReducer,
  state: .keyPath(\.myContact),
  id: .keyPath(\.?.id),
  action: /SessionAction.myContact,
  environment: \.myContact
)

#if DEBUG
extension SessionEnvironment {
  public static let failing = SessionEnvironment(
    getClient: { .failing },
    bgScheduler: .failing,
    mainScheduler: .failing,
    makeId: { fatalError() },
    error: .failing,
    myIdentity: .failing,
    myContact: .failing
  )
}
#endif
