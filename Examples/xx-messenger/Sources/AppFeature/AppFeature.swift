import ComposableArchitecture
import ComposablePresentation
import HomeFeature
import LaunchFeature

struct AppState: Equatable {
  enum Screen: Equatable {
    case launch(LaunchState)
    case home(HomeState)
  }

  var screen: Screen = .launch(LaunchState())
}

extension AppState.Screen {
  var asLaunch: LaunchState? {
    get { (/AppState.Screen.launch).extract(from: self) }
    set { if let newValue = newValue { self = .launch(newValue) } }
  }
  var asHome: HomeState? {
    get { (/AppState.Screen.home).extract(from: self) }
    set { if let newValue = newValue { self = .home(newValue) } }
  }
}

enum AppAction: Equatable {
  case home(HomeAction)
  case launch(LaunchAction)
}

struct AppEnvironment {
  var launch: () -> LaunchEnvironment
  var home: () -> HomeEnvironment
}

extension AppEnvironment {
  static let unimplemented = AppEnvironment(
    launch: { .unimplemented },
    home: { .unimplemented }
  )
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>
{ state, action, env in
  switch action {
  case .launch(.finished):
    state.screen = .home(HomeState())
    return .none

  case .launch(_), .home(_):
    return .none
  }
}
.presenting(
  launchReducer,
  state: .keyPath(\.screen.asLaunch),
  id: .notNil(),
  action: /AppAction.launch,
  environment: { $0.launch() }
)
.presenting(
  homeReducer,
  state: .keyPath(\.screen.asHome),
  id: .notNil(),
  action: /AppAction.home,
  environment: { $0.home() }
)
