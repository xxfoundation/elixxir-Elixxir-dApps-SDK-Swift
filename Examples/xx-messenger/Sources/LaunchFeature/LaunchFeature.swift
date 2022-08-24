import AppCore
import Combine
import ComposableArchitecture
import ComposablePresentation
import RegisterFeature
import RestoreFeature
import WelcomeFeature
import XXMessengerClient
import XXModels

public struct LaunchState: Equatable {
  public enum Screen: Equatable {
    case loading
    case welcome(WelcomeState)
    case restore(RestoreState)
    case register(RegisterState)
    case failure(String)
  }

  public init(
    screen: Screen = .loading
  ) {
    self.screen = screen
  }

  @BindableState public var screen: Screen
}

extension LaunchState.Screen {
  var asWelcome: WelcomeState? {
    get { (/LaunchState.Screen.welcome).extract(from: self) }
    set { if let state = newValue { self = .welcome(state) } }
  }
  var asRestore: RestoreState? {
    get { (/LaunchState.Screen.restore).extract(from: self) }
    set { if let state = newValue { self = .restore(state) } }
  }
  var asRegister: RegisterState? {
    get { (/LaunchState.Screen.register).extract(from: self) }
    set { if let state = newValue { self = .register(state) } }
  }
}

public enum LaunchAction: Equatable, BindableAction {
  case start
  case finished
  case binding(BindingAction<LaunchState>)
  case welcome(WelcomeAction)
  case restore(RestoreAction)
  case register(RegisterAction)
}

public struct LaunchEnvironment {
  public init(
    dbManager: DBManager,
    messenger: Messenger,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    bgQueue: AnySchedulerOf<DispatchQueue>,
    welcome: @escaping () -> WelcomeEnvironment,
    restore: @escaping () -> RestoreEnvironment,
    register: @escaping () -> RegisterEnvironment
  ) {
    self.dbManager = dbManager
    self.messenger = messenger
    self.mainQueue = mainQueue
    self.bgQueue = bgQueue
    self.welcome = welcome
    self.restore = restore
    self.register = register
  }

  public var dbManager: DBManager
  public var messenger: Messenger
  public var mainQueue: AnySchedulerOf<DispatchQueue>
  public var bgQueue: AnySchedulerOf<DispatchQueue>
  public var welcome: () -> WelcomeEnvironment
  public var restore: () -> RestoreEnvironment
  public var register: () -> RegisterEnvironment
}

extension LaunchEnvironment {
  public static let unimplemented = LaunchEnvironment(
    dbManager: .unimplemented,
    messenger: .unimplemented,
    mainQueue: .unimplemented,
    bgQueue: .unimplemented,
    welcome: { .unimplemented },
    restore: { .unimplemented },
    register: { .unimplemented }
  )
}

public let launchReducer = Reducer<LaunchState, LaunchAction, LaunchEnvironment>
{ state, action, env in
  switch action {
  case .start, .welcome(.finished), .restore(.finished), .register(.finished):
    state.screen = .loading
    return .future { fulfill in
      do {
        if env.dbManager.hasDB() == false {
          try env.dbManager.makeDB()
        }

        if env.messenger.isLoaded() == false {
          if env.messenger.isCreated() == false {
            fulfill(.success(.set(\.$screen, .welcome(WelcomeState()))))
            return
          }
          try env.messenger.load()
        }

        try env.messenger.start()

        if env.messenger.isConnected() == false {
          try env.messenger.connect()
        }

        if env.messenger.isLoggedIn() == false {
          if try env.messenger.isRegistered() == false {
            fulfill(.success(.set(\.$screen, .register(RegisterState()))))
            return
          }
          try env.messenger.logIn()
        }

        fulfill(.success(.finished))
      }
      catch {
        fulfill(.success(.set(\.$screen, .failure(error.localizedDescription))))
      }
    }
    .subscribe(on: env.bgQueue)
    .receive(on: env.mainQueue)
    .eraseToEffect()

  case .finished:
    return .none

  case .welcome(.restoreTapped):
    state.screen = .restore(RestoreState())
    return .none

  case .welcome(.failed(let failure)):
    state.screen = .failure(failure)
    return .none

  case .binding(_), .welcome(_), .restore(_), .register(_):
    return .none
  }
}
.binding()
.presenting(
  welcomeReducer,
  state: .keyPath(\.screen.asWelcome),
  id: .notNil(),
  action: /LaunchAction.welcome,
  environment: { $0.welcome() }
)
.presenting(
  restoreReducer,
  state: .keyPath(\.screen.asRestore),
  id: .notNil(),
  action: /LaunchAction.restore,
  environment: { $0.restore() }
)
.presenting(
  registerReducer,
  state: .keyPath(\.screen.asRegister),
  id: .notNil(),
  action: /LaunchAction.register,
  environment: { $0.register() }
)
