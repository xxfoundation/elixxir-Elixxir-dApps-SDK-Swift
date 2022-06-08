import Combine
import ComposableArchitecture
import ComposablePresentation
import ElixxirDAppsSDK
import ErrorFeature

public struct MyIdentityState: Equatable {
  public init(
    id: UUID,
    identity: Identity? = nil,
    isMakingIdentity: Bool = false,
    error: ErrorState? = nil
  ) {
    self.id = id
    self.isMakingIdentity = isMakingIdentity
    self.error = error
  }

  public var id: UUID
  public var identity: Identity?
  public var isMakingIdentity: Bool
  public var error: ErrorState?
}

public enum MyIdentityAction: Equatable {
  case viewDidLoad
  case observeMyIdentity
  case didUpdateMyIdentity(Identity?)
  case makeIdentity
  case didFinishMakingIdentity(NSError?)
  case didDismissError
  case error(ErrorAction)
}

public struct MyIdentityEnvironment {
  public init(
    getClient: @escaping () -> Client?,
    observeIdentity: @escaping () -> AnyPublisher<Identity?, Never>,
    updateIdentity: @escaping (Identity?) -> Void,
    bgScheduler: AnySchedulerOf<DispatchQueue>,
    mainScheduler: AnySchedulerOf<DispatchQueue>,
    error: ErrorEnvironment
  ) {
    self.getClient = getClient
    self.observeIdentity = observeIdentity
    self.updateIdentity = updateIdentity
    self.bgScheduler = bgScheduler
    self.mainScheduler = mainScheduler
    self.error = error
  }

  public var getClient: () -> Client?
  public var observeIdentity: () -> AnyPublisher<Identity?, Never>
  public var updateIdentity: (Identity?) -> Void
  public var bgScheduler: AnySchedulerOf<DispatchQueue>
  public var mainScheduler: AnySchedulerOf<DispatchQueue>
  public var error: ErrorEnvironment
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
    state.isMakingIdentity = true
    return Effect.future { fulfill in
      do {
        env.updateIdentity(try env.getClient()?.makeIdentity())
        fulfill(.success(.didFinishMakingIdentity(nil)))
      } catch {
        fulfill(.success(.didFinishMakingIdentity(error as NSError)))
      }
    }
    .subscribe(on: env.bgScheduler)
    .receive(on: env.mainScheduler)
    .eraseToEffect()

  case .didDismissError:
    state.error = nil
    return .none

  case .didFinishMakingIdentity(let error):
    state.isMakingIdentity = false
    if let error = error {
      state.error = ErrorState(error: error)
    }
    return .none
  }
}
.presenting(
  errorReducer,
  state: .keyPath(\.error),
  id: .keyPath(\.?.error),
  action: /MyIdentityAction.error,
  environment: \.error
)

#if DEBUG
extension MyIdentityEnvironment {
  public static let failing = MyIdentityEnvironment(
    getClient: { fatalError() },
    observeIdentity: { fatalError() },
    updateIdentity: { _ in fatalError() },
    bgScheduler: .failing,
    mainScheduler: .failing,
    error: .failing
  )
}
#endif
