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
  case makeIdentity
  case didFailMakingIdentity(NSError)
}

public struct MyIdentityEnvironment {
  public init(
    getClient: @escaping () -> Client?,
    observeIdentity: @escaping () -> AnyPublisher<Identity?, Never>,
    updateIdentity: @escaping (Identity?) -> Void,
    bgScheduler: AnySchedulerOf<DispatchQueue>,
    mainScheduler: AnySchedulerOf<DispatchQueue>
  ) {
    self.getClient = getClient
    self.observeIdentity = observeIdentity
    self.updateIdentity = updateIdentity
    self.bgScheduler = bgScheduler
    self.mainScheduler = mainScheduler
  }

  public var getClient: () -> Client?
  public var observeIdentity: () -> AnyPublisher<Identity?, Never>
  public var updateIdentity: (Identity?) -> Void
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

  case .makeIdentity:
    return Effect.run { subscriber in
      do {
        env.updateIdentity(try env.getClient()?.makeIdentity())
      } catch {
        subscriber.send(.didFailMakingIdentity(error as NSError))
      }
      subscriber.send(completion: .finished)
      return AnyCancellable {}
    }
    .subscribe(on: env.bgScheduler)
    .receive(on: env.mainScheduler)
    .eraseToEffect()

  case .didFailMakingIdentity(let error):
    return .none
  }
}

#if DEBUG
extension MyIdentityEnvironment {
  public static let failing = MyIdentityEnvironment(
    getClient: { fatalError() },
    observeIdentity: { fatalError() },
    updateIdentity: { _ in fatalError() },
    bgScheduler: .failing,
    mainScheduler: .failing
  )
}
#endif
