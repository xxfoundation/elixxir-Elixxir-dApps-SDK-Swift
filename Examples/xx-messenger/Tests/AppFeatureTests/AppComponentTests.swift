import AppCore
import ComposableArchitecture
import CustomDump
import HomeFeature
import RestoreFeature
import WelcomeFeature
import XCTest
import XXClient
@testable import AppFeature

final class AppComponentTests: XCTestCase {
  func testStartWithoutMessengerCreated() {
    var actions: [Action]!

    let store = TestStore(
      initialState: AppComponent.State(),
      reducer: AppComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.dbManager.hasDB.run = { false }
    store.dependencies.app.messenger.isLoaded.run = { false }
    store.dependencies.app.messenger.isCreated.run = { false }
    store.dependencies.app.dbManager.makeDB.run = {
      actions.append(.didMakeDB)
    }
    store.dependencies.app.authHandler.run = { _ in
      actions.append(.didStartAuthHandler)
      return Cancellable {}
    }
    store.dependencies.app.messageListener.run = { _ in
      actions.append(.didStartMessageListener)
      return Cancellable {}
    }
    store.dependencies.app.receiveFileHandler.run = { _ in
      actions.append(.didStartReceiveFileHandler)
      return Cancellable {}
    }
    store.dependencies.app.messenger.registerBackupCallback.run = { _ in
      actions.append(.didRegisterBackupCallback)
      return Cancellable {}
    }

    actions = []
    store.send(.start)

    store.receive(.set(\.$screen, .welcome(WelcomeComponent.State()))) {
      $0.screen = .welcome(WelcomeComponent.State())
    }
    XCTAssertNoDifference(actions, [
      .didMakeDB,
      .didStartAuthHandler,
      .didStartMessageListener,
      .didStartReceiveFileHandler,
      .didRegisterBackupCallback,
    ])

    store.send(.stop)
  }

  func testStartWithMessengerCreated() {
    var actions: [Action]!

    let store = TestStore(
      initialState: AppComponent.State(),
      reducer: AppComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.dbManager.hasDB.run = { false }
    store.dependencies.app.messenger.isLoaded.run = { false }
    store.dependencies.app.messenger.isCreated.run = { true }
    store.dependencies.app.dbManager.makeDB.run = {
      actions.append(.didMakeDB)
    }
    store.dependencies.app.messenger.load.run = {
      actions.append(.didLoadMessenger)
    }
    store.dependencies.app.authHandler.run = { _ in
      actions.append(.didStartAuthHandler)
      return Cancellable {}
    }
    store.dependencies.app.messageListener.run = { _ in
      actions.append(.didStartMessageListener)
      return Cancellable {}
    }
    store.dependencies.app.receiveFileHandler.run = { _ in
      actions.append(.didStartReceiveFileHandler)
      return Cancellable {}
    }
    store.dependencies.app.messenger.registerBackupCallback.run = { _ in
      actions.append(.didRegisterBackupCallback)
      return Cancellable {}
    }

    actions = []
    store.send(.start)

    store.receive(.set(\.$screen, .home(HomeComponent.State()))) {
      $0.screen = .home(HomeComponent.State())
    }
    XCTAssertNoDifference(actions, [
      .didMakeDB,
      .didStartAuthHandler,
      .didStartMessageListener,
      .didStartReceiveFileHandler,
      .didRegisterBackupCallback,
      .didLoadMessenger,
    ])

    store.send(.stop)
  }

  func testWelcomeFinished() {
    var actions: [Action]!

    let store = TestStore(
      initialState: AppComponent.State(
        screen: .welcome(WelcomeComponent.State())
      ),
      reducer: AppComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.dbManager.hasDB.run = { true }
    store.dependencies.app.messenger.isLoaded.run = { false }
    store.dependencies.app.messenger.isCreated.run = { true }
    store.dependencies.app.messenger.load.run = {
      actions.append(.didLoadMessenger)
    }
    store.dependencies.app.authHandler.run = { _ in
      actions.append(.didStartAuthHandler)
      return Cancellable {}
    }
    store.dependencies.app.messageListener.run = { _ in
      actions.append(.didStartMessageListener)
      return Cancellable {}
    }
    store.dependencies.app.receiveFileHandler.run = { _ in
      actions.append(.didStartReceiveFileHandler)
      return Cancellable {}
    }
    store.dependencies.app.messenger.registerBackupCallback.run = { _ in
      actions.append(.didRegisterBackupCallback)
      return Cancellable {}
    }

    actions = []
    store.send(.welcome(.finished)) {
      $0.screen = .loading
    }

    store.receive(.set(\.$screen, .home(HomeComponent.State()))) {
      $0.screen = .home(HomeComponent.State())
    }
    XCTAssertNoDifference(actions, [
      .didStartAuthHandler,
      .didStartMessageListener,
      .didStartReceiveFileHandler,
      .didRegisterBackupCallback,
      .didLoadMessenger,
    ])

    store.send(.stop)
  }

  func testRestoreFinished() {
    var actions: [Action]!

    let store = TestStore(
      initialState: AppComponent.State(
        screen: .restore(RestoreComponent.State())
      ),
      reducer: AppComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.dbManager.hasDB.run = { true }
    store.dependencies.app.messenger.isLoaded.run = { false }
    store.dependencies.app.messenger.isCreated.run = { true }
    store.dependencies.app.messenger.load.run = {
      actions.append(.didLoadMessenger)
    }
    store.dependencies.app.authHandler.run = { _ in
      actions.append(.didStartAuthHandler)
      return Cancellable {}
    }
    store.dependencies.app.messageListener.run = { _ in
      actions.append(.didStartMessageListener)
      return Cancellable {}
    }
    store.dependencies.app.receiveFileHandler.run = { _ in
      actions.append(.didStartReceiveFileHandler)
      return Cancellable {}
    }
    store.dependencies.app.messenger.registerBackupCallback.run = { _ in
      actions.append(.didRegisterBackupCallback)
      return Cancellable {}
    }

    actions = []
    store.send(.restore(.finished)) {
      $0.screen = .loading
    }

    store.receive(.set(\.$screen, .home(HomeComponent.State()))) {
      $0.screen = .home(HomeComponent.State())
    }
    XCTAssertNoDifference(actions, [
      .didStartAuthHandler,
      .didStartMessageListener,
      .didStartReceiveFileHandler,
      .didRegisterBackupCallback,
      .didLoadMessenger,
    ])

    store.send(.stop)
  }

  func testHomeDidDeleteAccount() {
    var actions: [Action]!

    let store = TestStore(
      initialState: AppComponent.State(
        screen: .home(HomeComponent.State())
      ),
      reducer: AppComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.dbManager.hasDB.run = { true }
    store.dependencies.app.messenger.isLoaded.run = { false }
    store.dependencies.app.messenger.isCreated.run = { false }
    store.dependencies.app.authHandler.run = { _ in
      actions.append(.didStartAuthHandler)
      return Cancellable {}
    }
    store.dependencies.app.messageListener.run = { _ in
      actions.append(.didStartMessageListener)
      return Cancellable {}
    }
    store.dependencies.app.receiveFileHandler.run = { _ in
      actions.append(.didStartReceiveFileHandler)
      return Cancellable {}
    }
    store.dependencies.app.messenger.registerBackupCallback.run = { _ in
      actions.append(.didRegisterBackupCallback)
      return Cancellable {}
    }

    actions = []
    store.send(.home(.deleteAccount(.success))) {
      $0.screen = .loading
    }

    store.receive(.set(\.$screen, .welcome(WelcomeComponent.State()))) {
      $0.screen = .welcome(WelcomeComponent.State())
    }
    XCTAssertNoDifference(actions, [
      .didStartAuthHandler,
      .didStartMessageListener,
      .didStartReceiveFileHandler,
      .didRegisterBackupCallback,
    ])

    store.send(.stop)
  }

  func testWelcomeRestoreTapped() {
    let store = TestStore(
      initialState: AppComponent.State(
        screen: .welcome(WelcomeComponent.State())
      ),
      reducer: AppComponent()
    )

    store.send(.welcome(.restoreTapped)) {
      $0.screen = .restore(RestoreComponent.State())
    }
  }

  func testWelcomeFailed() {
    let failure = "Something went wrong"

    let store = TestStore(
      initialState: AppComponent.State(
        screen: .welcome(WelcomeComponent.State())
      ),
      reducer: AppComponent()
    )

    store.send(.welcome(.failed(failure))) {
      $0.screen = .failure(failure)
    }
  }

  func testStartDatabaseMakeFailure() {
    struct Failure: Error {}
    let error = Failure()

    let store = TestStore(
      initialState: AppComponent.State(),
      reducer: AppComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.dbManager.hasDB.run = { false }
    store.dependencies.app.dbManager.makeDB.run = { throw error }

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
      initialState: AppComponent.State(),
      reducer: AppComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.dbManager.hasDB.run = { true }
    store.dependencies.app.messenger.isLoaded.run = { false }
    store.dependencies.app.messenger.isCreated.run = { true }
    store.dependencies.app.messenger.load.run = { throw error }
    store.dependencies.app.authHandler.run = { _ in
      actions.append(.didStartAuthHandler)
      return Cancellable {}
    }
    store.dependencies.app.messageListener.run = { _ in
      actions.append(.didStartMessageListener)
      return Cancellable {}
    }
    store.dependencies.app.receiveFileHandler.run = { _ in
      actions.append(.didStartReceiveFileHandler)
      return Cancellable {}
    }
    store.dependencies.app.messenger.registerBackupCallback.run = { _ in
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
      .didStartReceiveFileHandler,
      .didRegisterBackupCallback,
    ])

    store.send(.stop)
  }

  func testStartHandlersAndListeners() {
    var actions: [Action]!
    var authHandlerOnError: [AuthCallbackHandler.OnError] = []
    var messageListenerOnError: [MessageListenerHandler.OnError] = []
    var fileHandlerOnError: [ReceiveFileHandler.OnError] = []
    var backupCallback: [UpdateBackupFunc] = []

    let store = TestStore(
      initialState: AppComponent.State(),
      reducer: AppComponent()
    )

    store.dependencies.app.mainQueue = .immediate
    store.dependencies.app.bgQueue = .immediate
    store.dependencies.app.dbManager.hasDB.run = { true }
    store.dependencies.app.messenger.isLoaded.run = { true }
    store.dependencies.app.messenger.isCreated.run = { true }
    store.dependencies.app.authHandler.run = { onError in
      authHandlerOnError.append(onError)
      actions.append(.didStartAuthHandler)
      return Cancellable {
        actions.append(.didCancelAuthHandler)
      }
    }
    store.dependencies.app.messageListener.run = { onError in
      messageListenerOnError.append(onError)
      actions.append(.didStartMessageListener)
      return Cancellable {
        actions.append(.didCancelMessageListener)
      }
    }
    store.dependencies.app.receiveFileHandler.run = { onError in
      fileHandlerOnError.append(onError)
      actions.append(.didStartReceiveFileHandler)
      return Cancellable {
        actions.append(.didCancelReceiveFileHandler)
      }
    }
    store.dependencies.app.messenger.registerBackupCallback.run = { callback in
      backupCallback.append(callback)
      actions.append(.didRegisterBackupCallback)
      return Cancellable {
        actions.append(.didCancelBackupCallback)
      }
    }
    store.dependencies.app.log.run = { msg, _, _, _ in
      actions.append(.didLog(msg))
    }
    store.dependencies.app.backupStorage.store = { data in
      actions.append(.didStoreBackup(data))
    }

    actions = []
    store.send(.start)

    store.receive(.set(\.$screen, .home(HomeComponent.State()))) {
      $0.screen = .home(HomeComponent.State())
    }
    XCTAssertNoDifference(actions, [
      .didStartAuthHandler,
      .didStartMessageListener,
      .didStartReceiveFileHandler,
      .didRegisterBackupCallback,
    ])

    actions = []
    store.send(.start) {
      $0.screen = .loading
    }

    store.receive(.set(\.$screen, .home(HomeComponent.State()))) {
      $0.screen = .home(HomeComponent.State())
    }
    XCTAssertNoDifference(actions, [
      .didCancelAuthHandler,
      .didCancelMessageListener,
      .didCancelReceiveFileHandler,
      .didCancelBackupCallback,
      .didStartAuthHandler,
      .didStartMessageListener,
      .didStartReceiveFileHandler,
      .didRegisterBackupCallback,
    ])

    actions = []
    let authError = NSError(domain: "auth-handler-error", code: 1)
    authHandlerOnError.first?(authError)

    XCTAssertNoDifference(actions, [
      .didLog(.error(authError))
    ])

    actions = []
    let messageError = NSError(domain: "message-listener-error", code: 2)
    messageListenerOnError.first?(messageError)

    XCTAssertNoDifference(actions, [
      .didLog(.error(messageError))
    ])

    actions = []
    let fileError = NSError(domain: "receive-file-error", code: 3)
    fileHandlerOnError.first?(fileError)

    XCTAssertNoDifference(actions, [
      .didLog(.error(fileError))
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
      .didCancelReceiveFileHandler,
      .didCancelBackupCallback,
    ])
  }
}

private enum Action: Equatable {
  case didMakeDB
  case didStartAuthHandler
  case didStartMessageListener
  case didStartReceiveFileHandler
  case didRegisterBackupCallback
  case didLoadMessenger
  case didCancelAuthHandler
  case didCancelMessageListener
  case didCancelReceiveFileHandler
  case didCancelBackupCallback
  case didLog(Logger.Message)
  case didStoreBackup(Data)
}
