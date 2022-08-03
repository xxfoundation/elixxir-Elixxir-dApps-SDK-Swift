import Combine
import ComposableArchitecture
import ElixxirDAppsSDK
import ErrorFeature
import XCTestDynamicOverlay

public struct LandingState: Equatable {
  public init(
    id: UUID,
    hasStoredCmix: Bool = false,
    isMakingCmix: Bool = false,
    isRemovingCmix: Bool = false,
    error: ErrorState? = nil
  ) {
    self.id = id
    self.hasStoredCmix = hasStoredCmix
    self.isMakingCmix = isMakingCmix
    self.isRemovingCmix = isRemovingCmix
    self.error = error
  }

  var id: UUID
  var hasStoredCmix: Bool
  var isMakingCmix: Bool
  var isRemovingCmix: Bool
  var error: ErrorState?
}

public enum LandingAction: Equatable {
  case viewDidLoad
  case makeCmix
  case didMakeCmix
  case didFailMakingCmix(NSError)
  case removeStoredCmix
  case didRemoveStoredCmix
  case didFailRemovingStoredCmix(NSError)
  case didDismissError
  case error(ErrorAction)
}

public struct LandingEnvironment {
  public init(
    cmixManager: CmixManager,
    setCmix: @escaping (Cmix) -> Void,
    bgScheduler: AnySchedulerOf<DispatchQueue>,
    mainScheduler: AnySchedulerOf<DispatchQueue>,
    error: ErrorEnvironment
  ) {
    self.cmixManager = cmixManager
    self.setCmix = setCmix
    self.bgScheduler = bgScheduler
    self.mainScheduler = mainScheduler
    self.error = error
  }

  public var cmixManager: CmixManager
  public var setCmix: (Cmix) -> Void
  public var bgScheduler: AnySchedulerOf<DispatchQueue>
  public var mainScheduler: AnySchedulerOf<DispatchQueue>
  public var error: ErrorEnvironment
}

public let landingReducer = Reducer<LandingState, LandingAction, LandingEnvironment>
{ state, action, env in
  switch action {
  case .viewDidLoad:
    state.hasStoredCmix = env.cmixManager.hasStorage()
    return .none

  case .makeCmix:
    state.isMakingCmix = true
    return Effect.future { fulfill in
      do {
        if env.cmixManager.hasStorage() {
          env.setCmix(try env.cmixManager.load())
        } else {
          env.setCmix(try env.cmixManager.create())
        }
        fulfill(.success(.didMakeCmix))
      } catch {
        fulfill(.success(.didFailMakingCmix(error as NSError)))
      }
    }
    .subscribe(on: env.bgScheduler)
    .receive(on: env.mainScheduler)
    .eraseToEffect()

  case .didMakeCmix:
    state.isMakingCmix = false
    state.hasStoredCmix = env.cmixManager.hasStorage()
    return .none

  case .didFailMakingCmix(let error):
    state.isMakingCmix = false
    state.hasStoredCmix = env.cmixManager.hasStorage()
    state.error = ErrorState(error: error)
    return .none

  case .removeStoredCmix:
    state.isRemovingCmix = true
    return Effect.future { fulfill in
      do {
        try env.cmixManager.remove()
        fulfill(.success(.didRemoveStoredCmix))
      } catch {
        fulfill(.success(.didFailRemovingStoredCmix(error as NSError)))
      }
    }
    .subscribe(on: env.bgScheduler)
    .receive(on: env.mainScheduler)
    .eraseToEffect()

  case .didRemoveStoredCmix:
    state.isRemovingCmix = false
    state.hasStoredCmix = env.cmixManager.hasStorage()
    return .none

  case .didFailRemovingStoredCmix(let error):
    state.isRemovingCmix = false
    state.hasStoredCmix = env.cmixManager.hasStorage()
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
    cmixManager: .unimplemented,
    setCmix: XCTUnimplemented("\(Self.self).setCmix"),
    bgScheduler: .unimplemented,
    mainScheduler: .unimplemented,
    error: .unimplemented
  )
}
