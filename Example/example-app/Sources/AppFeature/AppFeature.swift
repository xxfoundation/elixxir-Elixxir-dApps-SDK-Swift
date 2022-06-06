import Combine
import ComposableArchitecture
import ComposablePresentation
import LandingFeature
import SessionFeature

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
  case clientDidChange(hasClient: Bool)
  case landing(LandingAction)
  case session(SessionAction)
}

struct AppEnvironment {
  var makeId: () -> UUID
  var hasClient: AnyPublisher<Bool, Never>
  var mainScheduler: AnySchedulerOf<DispatchQueue>
  var landing: LandingEnvironment
  var session: SessionEnvironment
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>
{ state, action, env in
  switch action {
  case .viewDidLoad:
    struct HasClientEffectId: Hashable {
      var id: UUID
    }
    return env.hasClient
      .removeDuplicates()
      .map(AppAction.clientDidChange(hasClient:))
      .receive(on: env.mainScheduler)
      .eraseToEffect()
      .cancellable(id: HasClientEffectId(id: state.id), cancelInFlight: true)

  case .clientDidChange(let hasClient):
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

#if DEBUG
extension AppEnvironment {
  static let failing = AppEnvironment(
    makeId: { fatalError() },
    hasClient: Empty().eraseToAnyPublisher(),
    mainScheduler: .failing,
    landing: .failing,
    session: .failing
  )
}
#endif
