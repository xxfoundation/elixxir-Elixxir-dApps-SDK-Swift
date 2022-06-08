import Combine
import ComposableArchitecture
import ElixxirDAppsSDK

public struct MyIdentityState: Equatable {
  public init(
    id: UUID
  ) {
    self.id = id
  }

  public var id: UUID
  public var identity: Identity?
}

public enum MyIdentityAction: Equatable {
  case viewDidLoad
  case observeMyIdentity
  case didUpdateMyIdentity(Identity?)
}

public struct MyIdentityEnvironment {
  public init(
    getClient: @escaping () -> Client?,
    observeIdentity: @escaping () -> AnyPublisher<Identity?, Never>,
    bgScheduler: AnySchedulerOf<DispatchQueue>,
    mainScheduler: AnySchedulerOf<DispatchQueue>
  ) {
    self.getClient = getClient
    self.observeIdentity = observeIdentity
    self.bgScheduler = bgScheduler
    self.mainScheduler = mainScheduler
  }

  public var getClient: () -> Client?
  public var observeIdentity: () -> AnyPublisher<Identity?, Never>
  public var bgScheduler: AnySchedulerOf<DispatchQueue>
  public var mainScheduler: AnySchedulerOf<DispatchQueue>
}

public let myIdentityReducer = Reducer<MyIdentityState, MyIdentityAction, MyIdentityEnvironment>
{ state, action, env in
  switch action {
  case .viewDidLoad:
    return .merge([
      .init(value: .observeMyIdentity),
    ])

  case .observeMyIdentity:
    struct EffectId: Hashable {
      let id: UUID
    }
    return env.observeIdentity()
      .removeDuplicates()
      .map(MyIdentityAction.didUpdateMyIdentity)
      .subscribe(on: env.bgScheduler)
      .receive(on: env.mainScheduler)
      .eraseToEffect()
      .cancellable(id: EffectId(id: state.id), cancelInFlight: true)

  case .didUpdateMyIdentity(let identity):
    state.identity = identity
    return .none
  }
}

#if DEBUG
extension MyIdentityEnvironment {
  public static let failing = MyIdentityEnvironment(
    getClient: { fatalError() },
    observeIdentity: { fatalError() },
    bgScheduler: .failing,
    mainScheduler: .failing
  )
}
#endif
