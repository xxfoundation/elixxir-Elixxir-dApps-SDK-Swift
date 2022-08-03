import Combine
import ComposableArchitecture
import ComposablePresentation
import LandingFeature
import SessionFeature
import XCTestDynamicOverlay

struct AppState: Equatable {
  enum Scene: Equatable {
    case landing(LandingState)
    case session(SessionState)
  }

  var id: UUID = UUID()
  var scene: Scene = .landing(LandingState(id: UUID()))
}

extension AppState.Scene {
  var asLanding: LandingState? {
    get {
      guard case .landing(let state) = self else { return nil }
      return state
    }
    set {
      guard let newValue = newValue else { return }
      self = .landing(newValue)
    }
  }

  var asSession: SessionState? {
    get {
      guard case .session(let state) = self else { return nil }
      return state
    }
    set {
      guard let newValue = newValue else { return }
      self = .session(newValue)
    }
  }
}

enum AppAction: Equatable {
  case viewDidLoad
  case cmixDidChange(hasCmix: Bool)
  case landing(LandingAction)
  case session(SessionAction)
}

struct AppEnvironment {
  var makeId: () -> UUID
  var hasCmix: () -> AnyPublisher<Bool, Never>
  var mainScheduler: AnySchedulerOf<DispatchQueue>
  var landing: LandingEnvironment
  var session: SessionEnvironment
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>
{ state, action, env in
  enum HasCmixEffectId {}

  switch action {
  case .viewDidLoad:
    return env.hasCmix()
      .removeDuplicates()
      .map(AppAction.cmixDidChange(hasCmix:))
      .receive(on: env.mainScheduler)
      .eraseToEffect()
      .cancellable(id: HasCmixEffectId.self, cancelInFlight: true)

  case .cmixDidChange(let hasClient):
    if hasClient {
      let sessionState = state.scene.asSession ?? SessionState(id: env.makeId())
      state.scene = .session(sessionState)
    } else {
      let landingState = state.scene.asLanding ?? LandingState(id: env.makeId())
      state.scene = .landing(landingState)
    }
    return .none

  case .landing(_), .session(_):
    return .none
  }
}
.presenting(
  landingReducer,
  state: .keyPath(\.scene.asLanding),
  id: .notNil(),
  action: /AppAction.landing,
  environment: \.landing
)
.presenting(
  sessionReducer,
  state: .keyPath(\.scene.asSession),
  id: .notNil(),
  action: /AppAction.session,
  environment: \.session
)

extension AppEnvironment {
  static let unimplemented = AppEnvironment(
    makeId: XCTUnimplemented("\(Self.self).makeId"),
    hasCmix: XCTUnimplemented("\(Self.self).hasCmix"),
    mainScheduler: .unimplemented,
    landing: .unimplemented,
    session: .unimplemented
  )
}
