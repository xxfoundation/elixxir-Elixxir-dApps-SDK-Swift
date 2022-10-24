import AppCore
import Combine
import ComposableArchitecture
import ComposablePresentation
import Foundation
import HomeFeature
import RestoreFeature
import WelcomeFeature
import XXClient
import XXMessengerClient

struct AppComponent: ReducerProtocol {
  struct State: Equatable {
    enum Screen: Equatable {
      case loading
      case welcome(WelcomeComponent.State)
      case restore(RestoreComponent.State)
      case home(HomeComponent.State)
      case failure(String)
    }

    @BindableState var screen: Screen = .loading
  }

  enum Action: Equatable, BindableAction {
    case setupLogging
    case start
    case stop
    case binding(BindingAction<State>)
    case welcome(WelcomeComponent.Action)
    case restore(RestoreComponent.Action)
    case home(HomeComponent.Action)
  }

  @Dependency(\.app.dbManager) var dbManager: DBManager
  @Dependency(\.app.messenger) var messenger: Messenger
  @Dependency(\.app.authHandler) var authHandler: AuthCallbackHandler
  @Dependency(\.app.messageListener) var messageListener: MessageListenerHandler
  @Dependency(\.app.receiveFileHandler) var receiveFileHandler: ReceiveFileHandler
  @Dependency(\.app.backupStorage) var backupStorage: BackupStorage
  @Dependency(\.app.log) var log: Logger
  @Dependency(\.app.mainQueue) var mainQueue: AnySchedulerOf<DispatchQueue>
  @Dependency(\.app.bgQueue) var bgQueue: AnySchedulerOf<DispatchQueue>

  var body: some ReducerProtocol<State, Action> {
    BindingReducer()
    Reduce { state, action in
      enum EffectId {}

      let dbManager = self.dbManager
      let messenger = self.messenger
      let authHandler = self.authHandler
      let messageListener = self.messageListener
      let receiveFileHandler = self.receiveFileHandler
      let backupStorage = self.backupStorage
      let log = self.log

      switch action {
      case .setupLogging:
        _ = try! messenger.setLogLevel(.debug)
        messenger.startLogging()
        return .none

      case .start, .welcome(.finished), .restore(.finished), .home(.deleteAccount(.success)):
        state.screen = .loading
        return Effect.run { subscriber in
          var cancellables: [XXClient.Cancellable] = []

          do {
            if dbManager.hasDB() == false {
              try dbManager.makeDB()
            }

            cancellables.append(authHandler(onError: { error in
              log(.error(error as NSError))
            }))
            cancellables.append(messageListener(onError: { error in
              log(.error(error as NSError))
            }))
            cancellables.append(receiveFileHandler(onError: { error in
              log(.error(error as NSError))
            }))

            cancellables.append(messenger.registerBackupCallback(.init { data in
              try? backupStorage.store(data)
            }))

            let isLoaded = messenger.isLoaded()
            let isCreated = messenger.isCreated()

            if !isLoaded, !isCreated {
              subscriber.send(.set(\.$screen, .welcome(WelcomeComponent.State())))
            } else if !isLoaded {
              try messenger.load()
              subscriber.send(.set(\.$screen, .home(HomeComponent.State())))
            } else {
              subscriber.send(.set(\.$screen, .home(HomeComponent.State())))
            }
          } catch {
            subscriber.send(.set(\.$screen, .failure(error.localizedDescription)))
          }

          return AnyCancellable { cancellables.forEach { $0.cancel() } }
        }
        .subscribe(on: bgQueue)
        .receive(on: mainQueue)
        .eraseToEffect()
        .cancellable(id: EffectId.self, cancelInFlight: true)

      case .stop:
        return .cancel(id: EffectId.self)

      case .welcome(.restoreTapped):
        state.screen = .restore(RestoreComponent.State())
        return .none

      case .welcome(.failed(let failure)):
        state.screen = .failure(failure)
        return .none

      case .binding(_), .welcome(_), .restore(_), .home(_):
        return .none
      }
    }
    .presenting(
      state: .keyPath(\.screen.asWelcome),
      id: .notNil(),
      action: /Action.welcome,
      presented: { WelcomeComponent() }
    )
    .presenting(
      state: .keyPath(\.screen.asRestore),
      id: .notNil(),
      action: /Action.restore,
      presented: { RestoreComponent() }
    )
    .presenting(
      state: .keyPath(\.screen.asHome),
      id: .notNil(),
      action: /Action.home,
      presented: { HomeComponent() }
    )
  }
}

extension AppComponent.State.Screen {
  var asWelcome: WelcomeComponent.State? {
    get { (/AppComponent.State.Screen.welcome).extract(from: self) }
    set { if let newValue = newValue { self = .welcome(newValue) } }
  }
  var asRestore: RestoreComponent.State? {
    get { (/AppComponent.State.Screen.restore).extract(from: self) }
    set { if let state = newValue { self = .restore(state) } }
  }
  var asHome: HomeComponent.State? {
    get { (/AppComponent.State.Screen.home).extract(from: self) }
    set { if let newValue = newValue { self = .home(newValue) } }
  }
}
