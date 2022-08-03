import Combine
import ComposableArchitecture
import ElixxirDAppsSDK
import ErrorFeature
import XCTestDynamicOverlay

public struct LandingState: Equatable {
  public init(
    id: UUID,
    hasStoredCMix: Bool = false,
    isMakingCMix: Bool = false,
    isRemovingCMix: Bool = false,
    error: ErrorState? = nil
  ) {
    self.id = id
    self.hasStoredCMix = hasStoredCMix
    self.isMakingCMix = isMakingCMix
    self.isRemovingCMix = isRemovingCMix
    self.error = error
  }

  var id: UUID
  var hasStoredCMix: Bool
  var isMakingCMix: Bool
  var isRemovingCMix: Bool
  var error: ErrorState?
}

public enum LandingAction: Equatable {
  case viewDidLoad
  case makeCMix
  case didMakeCMix
  case didFailMakingCMix(NSError)
  case removeStoredCMix
  case didRemoveStoredCMix
  case didFailRemovingStoredCMix(NSError)
  case didDismissError
  case error(ErrorAction)
}

public struct LandingEnvironment {
  public init(
    cMixManager: CMixManager,
    setCMix: @escaping (CMix) -> Void,
    bgScheduler: AnySchedulerOf<DispatchQueue>,
    mainScheduler: AnySchedulerOf<DispatchQueue>,
    error: ErrorEnvironment
  ) {
    self.cMixManager = cMixManager
    self.setCMix = setCMix
    self.bgScheduler = bgScheduler
    self.mainScheduler = mainScheduler
    self.error = error
  }

  public var cMixManager: CMixManager
  public var setCMix: (CMix) -> Void
  public var bgScheduler: AnySchedulerOf<DispatchQueue>
  public var mainScheduler: AnySchedulerOf<DispatchQueue>
  public var error: ErrorEnvironment
}

public let landingReducer = Reducer<LandingState, LandingAction, LandingEnvironment>
{ state, action, env in
  switch action {
  case .viewDidLoad:
    state.hasStoredCMix = env.cMixManager.hasStorage()
    return .none

  case .makeCMix:
    state.isMakingCMix = true
    return Effect.future { fulfill in
      do {
        if env.cMixManager.hasStorage() {
          env.setCMix(try env.cMixManager.load())
        } else {
          env.setCMix(try env.cMixManager.create())
        }
        fulfill(.success(.didMakeCMix))
      } catch {
        fulfill(.success(.didFailMakingCMix(error as NSError)))
      }
    }
    .subscribe(on: env.bgScheduler)
    .receive(on: env.mainScheduler)
    .eraseToEffect()

  case .didMakeCMix:
    state.isMakingCMix = false
    state.hasStoredCMix = env.cMixManager.hasStorage()
    return .none

  case .didFailMakingCMix(let error):
    state.isMakingCMix = false
    state.hasStoredCMix = env.cMixManager.hasStorage()
    state.error = ErrorState(error: error)
    return .none

  case .removeStoredCMix:
    state.isRemovingCMix = true
    return Effect.future { fulfill in
      do {
        try env.cMixManager.remove()
        fulfill(.success(.didRemoveStoredCMix))
      } catch {
        fulfill(.success(.didFailRemovingStoredCMix(error as NSError)))
      }
    }
    .subscribe(on: env.bgScheduler)
    .receive(on: env.mainScheduler)
    .eraseToEffect()

  case .didRemoveStoredCMix:
    state.isRemovingCMix = false
    state.hasStoredCMix = env.cMixManager.hasStorage()
    return .none

  case .didFailRemovingStoredCMix(let error):
    state.isRemovingCMix = false
    state.hasStoredCMix = env.cMixManager.hasStorage()
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

extension LandingEnvironment {
  public static let unimplemented = LandingEnvironment(
    cMixManager: .unimplemented,
    setCMix: XCTUnimplemented("\(Self.self).setCMix"),
    bgScheduler: .unimplemented,
    mainScheduler: .unimplemented,
    error: .unimplemented
  )
}
