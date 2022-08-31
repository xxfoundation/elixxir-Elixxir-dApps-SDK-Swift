import AppCore
import Combine
import ComposableArchitecture
import ComposablePresentation
import Foundation
import HomeFeature
import RestoreFeature
import WelcomeFeature
import XXMessengerClient

struct AppState: Equatable {
  enum Screen: Equatable {
    case loading
    case welcome(WelcomeState)
    case restore(RestoreState)
    case home(HomeState)
    case failure(String)
  }

  @BindableState var screen: Screen = .loading
}

extension AppState.Screen {
  var asWelcome: WelcomeState? {
    get { (/AppState.Screen.welcome).extract(from: self) }
    set { if let newValue = newValue { self = .welcome(newValue) } }
  }
  var asRestore: RestoreState? {
    get { (/AppState.Screen.restore).extract(from: self) }
    set { if let state = newValue { self = .restore(state) } }
  }
  var asHome: HomeState? {
    get { (/AppState.Screen.home).extract(from: self) }
    set { if let newValue = newValue { self = .home(newValue) } }
  }
}

enum AppAction: Equatable, BindableAction {
  case start
  case binding(BindingAction<AppState>)
  case welcome(WelcomeAction)
  case restore(RestoreAction)
  case home(HomeAction)
}

struct AppEnvironment {
  var dbManager: DBManager
  var messenger: Messenger
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var bgQueue: AnySchedulerOf<DispatchQueue>
  var welcome: () -> WelcomeEnvironment
  var restore: () -> RestoreEnvironment
  var home: () -> HomeEnvironment
}

extension AppEnvironment {
  static let unimplemented = AppEnvironment(
    dbManager: .unimplemented,
    messenger: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented,
    welcome: { .unimplemented },
    restore: { .unimplemented },
    home: { .unimplemented }
  )
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>
{ state, action, env in
  switch action {
  case .start, .welcome(.finished), .restore(.finished):
    state.screen = .loading
    return .run { subscriber in
      do {
        if env.dbManager.hasDB() == false {
          try env.dbManager.makeDB()
        }

        if env.messenger.isLoaded() == false {
          if env.messenger.isCreated() == false {
            subscriber.send(.set(\.$screen, .welcome(WelcomeState())))
            subscriber.send(completion: .finished)
            return AnyCancellable {}
          }
          try env.messenger.load()
        }

        subscriber.send(.set(\.$screen, .home(HomeState())))
      } catch {
        subscriber.send(.set(\.$screen, .failure(error.localizedDescription)))
      }
      subscriber.send(completion: .finished)
      return AnyCancellable {}
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .welcome(.restoreTapped):
    state.screen = .restore(RestoreState())
    return .none

  case .welcome(.failed(let failure)):
    state.screen = .failure(failure)
    return .none

  case .binding(_), .welcome(_), .restore(_), .home(_):
    return .none
  }
}
.binding()
.presenting(
  welcomeReducer,
  state: .keyPath(\.screen.asWelcome),
  id: .notNil(),
  action: /AppAction.welcome,
  environment: { $0.welcome() }
)
.presenting(
  restoreReducer,
  state: .keyPath(\.screen.asRestore),
  id: .notNil(),
  action: /AppAction.restore,
  environment: { $0.restore() }
)
.presenting(
  homeReducer,
  state: .keyPath(\.screen.asHome),
  id: .notNil(),
  action: /AppAction.home,
  environment: { $0.home() }
)
