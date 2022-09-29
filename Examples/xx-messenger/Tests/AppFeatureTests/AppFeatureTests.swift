import AppCore
import ComposableArchitecture
import CustomDump
import HomeFeature
import RestoreFeature
import WelcomeFeature
import XCTest
import XXClient
@testable import AppFeature

final class AppFeatureTests: XCTestCase {
  func testStartWithoutMessengerCreated() {
    var actions: [Action]!

    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.dbManager.hasDB.run = { false }
    store.environment.messenger.isLoaded.run = { false }
    store.environment.messenger.isCreated.run = { false }
    store.environment.dbManager.makeDB.run = {
      actions.append(.didMakeDB)
    }
    store.environment.authHandler.run = { _ in
      actions.append(.didStartAuthHandler)
      return Cancellable {}
    }
    store.environment.messageListener.run = { _ in
      actions.append(.didStartMessageListener)
      return Cancellable {}
    }
    store.environment.messenger.registerBackupCallback.run = { _ in
      actions.append(.didRegisterBackupCallback)
      return Cancellable {}
    }

    actions = []
    store.send(.start)

    store.receive(.set(\.$screen, .welcome(WelcomeState()))) {
      $0.screen = .welcome(WelcomeState())
    }
    XCTAssertNoDifference(actions, [
      .didMakeDB,
      .didStartAuthHandler,
      .didStartMessageListener,
      .didRegisterBackupCallback,
    ])

    store.send(.stop)
  }

  func testStartWithMessengerCreated() {
    var actions: [Action]!

    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.dbManager.hasDB.run = { false }
    store.environment.messenger.isLoaded.run = { false }
    store.environment.messenger.isCreated.run = { true }
    store.environment.dbManager.makeDB.run = {
      actions.append(.didMakeDB)
    }
    store.environment.messenger.load.run = {
      actions.append(.didLoadMessenger)
    }
    store.environment.authHandler.run = { _ in
      actions.append(.didStartAuthHandler)
      return Cancellable {}
    }
    store.environment.messageListener.run = { _ in
      actions.append(.didStartMessageListener)
      return Cancellable {}
    }
    store.environment.messenger.registerBackupCallback.run = { _ in
      actions.append(.didRegisterBackupCallback)
      return Cancellable {}
    }

    actions = []
    store.send(.start)

    store.receive(.set(\.$screen, .home(HomeState()))) {
      $0.screen = .home(HomeState())
    }
    XCTAssertNoDifference(actions, [
      .didMakeDB,
      .didStartAuthHandler,
      .didStartMessageListener,
      .didRegisterBackupCallback,
      .didLoadMessenger,
    ])

    store.send(.stop)
  }

  func testWelcomeFinished() {
    var actions: [Action]!

    let store = TestStore(
      initialState: AppState(
        screen: .welcome(WelcomeState())
      ),
      reducer: appReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.dbManager.hasDB.run = { true }
    store.environment.messenger.isLoaded.run = { false }
    store.environment.messenger.isCreated.run = { true }
    store.environment.messenger.load.run = {
      actions.append(.didLoadMessenger)
    }
    store.environment.authHandler.run = { _ in
      actions.append(.didStartAuthHandler)
      return Cancellable {}
    }
    store.environment.messageListener.run = { _ in
      actions.append(.didStartMessageListener)
      return Cancellable {}
    }
    store.environment.messenger.registerBackupCallback.run = { _ in
      actions.append(.didRegisterBackupCallback)
      return Cancellable {}
    }

    actions = []
    store.send(.welcome(.finished)) {
      $0.screen = .loading
    }

    store.receive(.set(\.$screen, .home(HomeState()))) {
      $0.screen = .home(HomeState())
    }
    XCTAssertNoDifference(actions, [
      .didStartAuthHandler,
      .didStartMessageListener,
      .didRegisterBackupCallback,
      .didLoadMessenger,
    ])

    store.send(.stop)
  }

  func testRestoreFinished() {
    var actions: [Action]!

    let store = TestStore(
      initialState: AppState(
        screen: .restore(RestoreState())
      ),
      reducer: appReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.dbManager.hasDB.run = { true }
    store.environment.messenger.isLoaded.run = { false }
    store.environment.messenger.isCreated.run = { true }
    store.environment.messenger.load.run = {
      actions.append(.didLoadMessenger)
    }
    store.environment.authHandler.run = { _ in
      actions.append(.didStartAuthHandler)
      return Cancellable {}
    }
    store.environment.messageListener.run = { _ in
      actions.append(.didStartMessageListener)
      return Cancellable {}
    }
    store.environment.messenger.registerBackupCallback.run = { _ in
      actions.append(.didRegisterBackupCallback)
      return Cancellable {}
    }

    actions = []
    store.send(.restore(.finished)) {
      $0.screen = .loading
    }

    store.receive(.set(\.$screen, .home(HomeState()))) {
      $0.screen = .home(HomeState())
    }
    XCTAssertNoDifference(actions, [
      .didStartAuthHandler,
      .didStartMessageListener,
      .didRegisterBackupCallback,
      .didLoadMessenger,
    ])

    store.send(.stop)
  }

  func testHomeDidDeleteAccount() {
    var actions: [Action]!

    let store = TestStore(
      initialState: AppState(
        screen: .home(HomeState())
      ),
      reducer: appReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.dbManager.hasDB.run = { true }
    store.environment.messenger.isLoaded.run = { false }
    store.environment.messenger.isCreated.run = { false }
    store.environment.authHandler.run = { _ in
      actions.append(.didStartAuthHandler)
      return Cancellable {}
    }
    store.environment.messageListener.run = { _ in
      actions.append(.didStartMessageListener)
      return Cancellable {}
    }
    store.environment.messenger.registerBackupCallback.run = { _ in
      actions.append(.didRegisterBackupCallback)
      return Cancellable {}
    }

    actions = []
    store.send(.home(.deleteAccount(.success))) {
      $0.screen = .loading
    }

    store.receive(.set(\.$screen, .welcome(WelcomeState()))) {
      $0.screen = .welcome(WelcomeState())
    }
    XCTAssertNoDifference(actions, [
      .didStartAuthHandler,
      .didStartMessageListener,
      .didRegisterBackupCallback,
    ])

    store.send(.stop)
  }

  func testWelcomeRestoreTapped() {
    let store = TestStore(
      initialState: AppState(
        screen: .welcome(WelcomeState())
      ),
      reducer: appReducer,
      environment: .unimplemented
    )

    store.send(.welcome(.restoreTapped)) {
      $0.screen = .restore(RestoreState())
    }
  }

  func testWelcomeFailed() {
    let failure = "Something went wrong"

    let store = TestStore(
      initialState: AppState(
        screen: .welcome(WelcomeState())
      ),
      reducer: appReducer,
      environment: .unimplemented
    )

    store.send(.welcome(.failed(failure))) {
      $0.screen = .failure(failure)
    }
  }

  func testStartDatabaseMakeFailure() {
    struct Failure: Error {}
    let error = Failure()

    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.dbManager.hasDB.run = { false }
    store.environment.dbManager.makeDB.run = { throw error }

    store.send(.start)

    store.receive(.set(\.$screen, .failure(error.localizedDescription))) {
      $0.screen = .failure(error.localizedDescription)
    }

    store.send(.stop)
  }

  func testStartMessengerLoadFailure() {
    struct Failure: Error {}
    let error = Failure()

    var actions: [Action]!

    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.dbManager.hasDB.run = { true }
    store.environment.messenger.isLoaded.run = { false }
    store.environment.messenger.isCreated.run = { true }
    store.environment.messenger.load.run = { throw error }
    store.environment.authHandler.run = { _ in
      actions.append(.didStartAuthHandler)
      return Cancellable {}
    }
    store.environment.messageListener.run = { _ in
      actions.append(.didStartMessageListener)
      return Cancellable {}
    }
    store.environment.messenger.registerBackupCallback.run = { _ in
      actions.append(.didRegisterBackupCallback)
      return Cancellable {}
    }

    actions = []
    store.send(.start)

    store.receive(.set(\.$screen, .failure(error.localizedDescription))) {
      $0.screen = .failure(error.localizedDescription)
    }

    XCTAssertNoDifference(actions, [
      .didStartAuthHandler,
      .didStartMessageListener,
      .didRegisterBackupCallback,
    ])

    store.send(.stop)
  }

  func testStartHandlersAndListeners() {
    var actions: [Action]!
    var authHandlerOnError: [AuthCallbackHandler.OnError] = []
    var messageListenerOnError: [MessageListenerHandler.OnError] = []
    var backupCallback: [UpdateBackupFunc] = []

    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: .unimplemented
    )

    store.environment.mainQueue = .immediate
    store.environment.bgQueue = .immediate
    store.environment.dbManager.hasDB.run = { true }
    store.environment.messenger.isLoaded.run = { true }
    store.environment.messenger.isCreated.run = { true }
    store.environment.authHandler.run = { onError in
      authHandlerOnError.append(onError)
      actions.append(.didStartAuthHandler)
      return Cancellable {
        actions.append(.didCancelAuthHandler)
      }
    }
    store.environment.messageListener.run = { onError in
      messageListenerOnError.append(onError)
      actions.append(.didStartMessageListener)
      return Cancellable {
        actions.append(.didCancelMessageListener)
      }
    }
    store.environment.messenger.registerBackupCallback.run = { callback in
      backupCallback.append(callback)
      actions.append(.didRegisterBackupCallback)
      return Cancellable {
        actions.append(.didCancelBackupCallback)
      }
    }
    store.environment.log.run = { msg, _, _, _ in
      actions.append(.didLog(msg))
    }
    store.environment.backupStorage.store = { data in
      actions.append(.didStoreBackup(data))
    }

    actions = []
    store.send(.start)

    store.receive(.set(\.$screen, .home(HomeState()))) {
      $0.screen = .home(HomeState())
    }
    XCTAssertNoDifference(actions, [
      .didStartAuthHandler,
      .didStartMessageListener,
      .didRegisterBackupCallback,
    ])

    actions = []
    store.send(.start) {
      $0.screen = .loading
    }

    store.receive(.set(\.$screen, .home(HomeState()))) {
      $0.screen = .home(HomeState())
    }
    XCTAssertNoDifference(actions, [
      .didCancelAuthHandler,
      .didCancelMessageListener,
      .didCancelBackupCallback,
      .didStartAuthHandler,
      .didStartMessageListener,
      .didRegisterBackupCallback,
    ])

    actions = []
    struct AuthError: Error {}
    let authError = AuthError()
    authHandlerOnError.first?(authError)

    XCTAssertNoDifference(actions, [
      .didLog(.error(authError as NSError))
    ])

    actions = []
    struct MessageError: Error {}
    let messageError = MessageError()
    messageListenerOnError.first?(messageError)

    XCTAssertNoDifference(actions, [
      .didLog(.error(messageError as NSError))
    ])

    actions = []
    let backupData = "backup".data(using: .utf8)!
    backupCallback.first?.handle(backupData)

    XCTAssertNoDifference(actions, [
      .didStoreBackup(backupData),
    ])

    actions = []
    store.send(.stop)

    XCTAssertNoDifference(actions, [
      .didCancelAuthHandler,
      .didCancelMessageListener,
      .didCancelBackupCallback,
    ])
  }
}

private enum Action: Equatable {
  case didMakeDB
  case didStartAuthHandler
  case didStartMessageListener
  case didRegisterBackupCallback
  case didLoadMessenger
  case didCancelAuthHandler
  case didCancelMessageListener
  case didCancelBackupCallback
  case didLog(Logger.Message)
  case didStoreBackup(Data)
}
