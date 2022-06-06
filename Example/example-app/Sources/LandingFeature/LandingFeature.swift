import Combine
import ComposableArchitecture
import ElixxirDAppsSDK
import ErrorFeature

public struct LandingState: Equatable {
  public init(
    id: UUID,
    hasStoredClient: Bool = false,
    isMakingClient: Bool = false,
    isRemovingClient: Bool = false,
    error: ErrorState? = nil
  ) {
    self.id = id
    self.hasStoredClient = hasStoredClient
    self.isMakingClient = isMakingClient
    self.isRemovingClient = isRemovingClient
    self.error = error
  }

  var id: UUID
  var hasStoredClient: Bool
  var isMakingClient: Bool
  var isRemovingClient: Bool
  var error: ErrorState?
}

public enum LandingAction: Equatable {
  case viewDidLoad
  case makeClient
  case didMakeClient
  case didFailMakingClient(NSError)
  case removeStoredClient
  case didRemoveStoredClient
  case didFailRemovingStoredClient(NSError)
  case didDismissError
  case error(ErrorAction)
}

public struct LandingEnvironment {
  public init(
    clientStorage: ClientStorage,
    setClient: @escaping (Client) -> Void,
    bgScheduler: AnySchedulerOf<DispatchQueue>,
    mainScheduler: AnySchedulerOf<DispatchQueue>,
    error: ErrorEnvironment
  ) {
    self.clientStorage = clientStorage
    self.setClient = setClient
    self.bgScheduler = bgScheduler
    self.mainScheduler = mainScheduler
    self.error = error
  }

  public var clientStorage: ClientStorage
  public var setClient: (Client) -> Void
  public var bgScheduler: AnySchedulerOf<DispatchQueue>
  public var mainScheduler: AnySchedulerOf<DispatchQueue>
  public var error: ErrorEnvironment
}

public let landingReducer = Reducer<LandingState, LandingAction, LandingEnvironment>
{ state, action, env in
  switch action {
  case .viewDidLoad:
    state.hasStoredClient = env.clientStorage.hasStoredClient()
    return .none

  case .makeClient:
    state.isMakingClient = true
    return Effect.future { fulfill in
      do {
        if env.clientStorage.hasStoredClient() {
          env.setClient(try env.clientStorage.loadClient())
        } else {
          env.setClient(try env.clientStorage.createClient())
        }
        fulfill(.success(.didMakeClient))
      } catch {
        fulfill(.success(.didFailMakingClient(error as NSError)))
      }
    }
    .subscribe(on: env.bgScheduler)
    .receive(on: env.mainScheduler)
    .eraseToEffect()

  case .didMakeClient:
    state.isMakingClient = false
    state.hasStoredClient = env.clientStorage.hasStoredClient()
    return .none

  case .didFailMakingClient(let error):
    state.isMakingClient = false
    state.hasStoredClient = env.clientStorage.hasStoredClient()
    state.error = ErrorState(error: error)
    return .none

  case .removeStoredClient:
    state.isRemovingClient = true
    return Effect.future { fulfill in
      do {
        try env.clientStorage.removeClient()
        fulfill(.success(.didRemoveStoredClient))
      } catch {
        fulfill(.success(.didFailRemovingStoredClient(error as NSError)))
      }
    }
    .subscribe(on: env.bgScheduler)
    .receive(on: env.mainScheduler)
    .eraseToEffect()

  case .didRemoveStoredClient:
    state.isRemovingClient = false
    state.hasStoredClient = env.clientStorage.hasStoredClient()
    return .none

  case .didFailRemovingStoredClient(let error):
    state.isRemovingClient = false
    state.hasStoredClient = env.clientStorage.hasStoredClient()
    state.error = ErrorState(error: error)
    return .none

  case .didDismissError:
    state.error = nil
    return .none
  }
}
.presenting(
  errorReducer,
  state: .keyPath(\.error),
  id: .keyPath(\.?.error),
  action: /LandingAction.error,
  environment: \.error
)

#if DEBUG
extension LandingEnvironment {
  public static let failing = LandingEnvironment(
    clientStorage: .failing,
    setClient: { _ in fatalError() },
    bgScheduler: .failing,
    mainScheduler: .failing,
    error: .failing
  )
}
#endif
